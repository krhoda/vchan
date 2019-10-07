module channel

import sync

struct Chan {
mut:
	val string

	s_wait bool
	s_mu sync.Mutex
	s_wg sync.WaitGroup

	r_wait bool
	r_mu sync.Mutex
	r_wg sync.WaitGroup
}

pub fn new_chan() &Chan {
	mut c := &Chan{
		val: ''
	}

	c.s_wg.add(1)
	c.r_wg.add(1)

	return c
}


pub fn (c mut Chan) send(payload string) {
	c.s_mu.lock() // prevent other senders. if recieved, safe to mutate.

	// err check
	c.s_wait = true // tells close the step incremented
	c.r_wg.wait() // detect recv exists
	c.s_wait = false // tells close we've passed the wait that might've needed help.

	c.r_wg.add(1) // block next sender for recv

	c.val = payload // finally.

	c.s_wg.done() // inform other send exists

	c.s_mu.unlock() // complete 
	return
}


pub fn (c mut Chan) recv() string {
	c.r_mu.lock() // prevent other recv

	c.r_wg.done() // inform the send we exist

	// err check
	c.r_wait = true // tells close the step incremented
	c.s_wg.wait() // detects send xists
	c.r_wait = false // tells close we've passed the wait that might've needed help.

	c.s_wg.add(1) // stops next recv from running without a send.

	i := c.val
	c.val = ''

	defer { c.r_mu.unlock() }

	return i
}
