module main

import vchan

fn main() {
	msg := 'TEST V'

	mut c := &vchan.Vchan{}
	c.init_chan()

	go c.send(msg)
	mut x := c.recv()
	println(x)

	go c.send(msg)
	x = c.recv()
	println(x)

	go c.send(msg)
	go c.send(msg)

	x = c.recv()
	println(x)
	x = c.recv()
	println(x)

	println('phew')
}
