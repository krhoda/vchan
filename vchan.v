module vchan

import sync

struct Vchan<T> {
mut:
	val T

	s_wait bool
	s_mu sync.Mutex
	s_wg sync.WaitGroup

	r_wait bool
	r_mu sync.Mutex
	r_wg sync.WaitGroup
}

pub fn new_vchan(a T) &Vchan<T> {
	mut v := &Vchan<T>{}

	v.s_wg.add(1)
	v.r_wg.add(1)

	return v
}


pub fn (v mut Vchan<T>) send(payload T) {
	v.s_mu.lock() // prevent other senders. if recieved, safe to mutate.

	// err check
	v.s_wait = true // tells close the step incremented
	v.r_wg.wait() // detect recv exists
	v.s_wait = false // tells close we've passed the wait that might've needed help.

	v.r_wg.add(1) // block next sender for recv

	v.val = payload // finally.

	v.s_wg.done() // inform other send exists

	v.s_mu.unlock() // complete 
	return
}


pub fn (v mut Vchan<T>) recv() T {
	v.r_mu.lock() // prevent other recv

	v.r_wg.done() // inform the send we exist

	// err check
	v.r_wait = true // tells close the step incremented
	v.s_wg.wait() // detects send xists
	v.r_wait = false // tells close we've passed the wait that might've needed help.

	v.s_wg.add(1) // stops next recv from running without a send.

	i := v.val
	// NOTE: REMOVED RESETTING VAL TO ZERO VALUE.
	// DOES IT NEED TO REPLACE WITH BOOL OF "fizzled" ALA GHCI SPARKS?
	// v.val = ''

	defer { v.r_mu.unlock() }

	return i
}
