module vchan

import sync

pub struct Vchan {
mut:
	val string

	init bool
	closed bool

	s_wait bool
	s_mu sync.Mutex
	s_wg sync.WaitGroup

	r_wait bool
	r_mu sync.Mutex
	r_wg sync.WaitGroup
}

fn (v mut Vchan) is_alive() bool {
	return v.init && !v.closed
}

fn (v mut Vchan) is_dead() bool {
	return !v.is_alive()
}

pub fn (v mut Vchan) init_chan() {
	if v.init {
		return
	}

	v.init = true
	v.closed = false
	v.s_wg.add(1)
	v.r_wg.add(1)
}

pub fn (v mut Vchan) send(payload string) ?bool {
	if v.is_dead() {
		return error('Channel cannot be sent on. Closed: $v.closed, Initialized: $v.init')
	}

	v.s_mu.lock() // prevent other senders. if recieved, safe to mutate.

	// err check
	v.s_wait = true // tells close the step incremented
	v.r_wg.wait() // detect recv exists
	v.s_wait = false // tells close we've passed the wait that might've needed help.

	v.r_wg.add(1) // block next sender for recv

	v.val = payload // finally.

	v.s_wg.done() // inform other send exists

	v.s_mu.unlock() // complete 

	return true
}


pub fn (v mut Vchan) recv() string {
	if v.is_dead() {
		return ''
		// TODO: Make err
		// return error('Channel cannot be recvd on. Closed: $v.closed, Initialized: $v.init')
		// main.v:13:11: `?string` needs to have method `str() string` to be printable
	}

	v.r_mu.lock() // prevent other recv

	v.r_wg.done() // inform the send we exist

	// err check
	v.r_wait = true // tells close the step incremented
	v.s_wg.wait() // detects send exists
	v.r_wait = false // tells close we've passed the wait that might've needed help.

	v.s_wg.add(1) // stops next recv from running without a send.

	i := v.val

	// Not sure if this is needed.
	// v.val = ''

	defer { v.r_mu.unlock() }

	return i
}

struct Result {
	val string
	is_good bool
}

pub fn (r Result) good() bool {
	return r.is_good
}

pub fn (r Result) get_val() string {
	return r.val
}

pub fn (v mut Vchan) sample() Result {
	r := Result{
		val: '',
		is_good: false,
	}

	if v.is_dead() {
		return r
		// TODO: Make err
	}

	if v.s_wait { // is there a sender waiting RIGHT NOW!?
		v.r_mu.lock() // take the receiver lock
		defer { v.r_mu.unlock() }

		if v.s_wait { // Did someone else recv the send?
			v.r_wg.done() // inform the send we exist

			// err check
			v.r_wait = true // tells close the step incremented
			v.s_wg.wait() // detects send exists, which we know it does.
			v.r_wait = false // tells close we've passed the wait that might've needed help.

			v.s_wg.add(1) // stops next recv from running without a send.
			// v.val = ''

			return Result{
				val: v.val,
				is_good: true
			}

		}
	}

	return r
}
