module main

import vchan

fn main() {
	msg := 'TEST V'

	mut c := &vchan.Vchan{}
	c.init_chan()

	go c.send('Hi')
	mut x := c.recv()
	println(x)

	go c.send(msg)
	x = c.recv()
	println(x)

	go c.send('Yo')
	go c.send(msg)

	x = c.recv()
	println(x)

	y := c.sample()
	if y.good() {
		println(y.get_val())
	} else {
		println('Y was bad!')
	}

	z := c.sample()
	if z.good() {
		println(z.get_val())
	} else {
		println('Z was bad!')
	}

	println('phew')
}
