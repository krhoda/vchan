module channel

import sync

pub fn new_chan() &Chan {
	c := &Chan{
		hear_val: ''
		send_ready: false
		receive_ready: false
	}

	return c
}

pub fn listen(c mut Chan) {
	i := c.hear()

	println('???')
	println(i)
	println('!!!')
}

// interface Anyer {}
struct Chan {
mut:
	send_guard sync.Mutex
	hear_guard sync.Mutex
	ready_sig  sync.Mutex

	/* hear_val []byte */
	hear_val string
	send_ready bool
	receive_ready bool
}

/* fn (c mut Chan) send(a []byte) { */
fn (c mut Chan) send(a string) {
	c.send_guard.lock() // prevent other senders. if recieved, safe to mutate.
	c.ready_sig.lock()

	c.send_ready = true

	for !c.receive_ready {

	}

	c.hear_val = a // mutate wrapped value.
	c.ready_sig.unlock() // open a listener.

	return
}

/* fn (c mut Chan) hear() []byte { */
fn (c mut Chan) hear() string {
	println('a')
	c.hear_guard.lock()
	for !c.send_ready {
	
	}

	c.receive_ready = true
	c.ready_sig.lock()

	i := c.hear_val

	defer { c.reset() }

	return i
}

fn (c mut Chan) reset() {
	c.send_ready = false
	c.receive_ready = false
	c.ready_sig.unlock()
	c.send_guard.unlock()
	c.hear_guard.unlock()
}

