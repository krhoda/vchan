# Vchan
## A Simple and Powerful Concurrency Primative

### Purpose and Usage:
Vchan is an attempt to bring simple, predictable cross-coroutine communication to V.

Vchan rejects the cognative overhead of 'i' before 'e' except after 'c' and describes the act of awaiting and obtaining a message as to `recv` and one who `recv`s is a `recver` etc.

Usage is similar to golang channels, `send` and `recv` functions instead of `<-` semantics. All channels block on both `send` and `recv`. When execution resumes on both threads, true synchronization has been assured, the data copied, and the channel cleared of data. When a channel is closed, sends and recvs encounter the optional error, and data is cleared. Non-blocking sends can be achieved with the use of additional coroutines (`go my_vchan.send("hello")`). Non-blocking recvs can be achieved with `sample`.

NOTHING IS CURRENTLY STABLE

### Goals and Progress:

Vchan is a work in progress with a clear end-goal and idea of what "done" is. A completed VChan would be a module capable of:
* Public fn initializing and exposing the Vchan structure.
  * The fn is generic
  * The structure is generic
* A send mechanism that blocks until a recver ready to recv.
* A recv mechanism that blocks until a sender is ready to send.
* A reasonable attempt at FIFO. Perfect race-conditions handled in a quasi-random order.
* Reasonable close semantics. Close fires ?options in send/recv, clears all internal locks, empties all data. To the user, all of this is just `vchan.close(my_vchan)`

Things that would be of great interest, and *might* be provided by VChan:
* Select structure
* Buffered channels 

### Where We Are:

* Public fn initializing and exposing the Vchan structure.
  * The fn is string only
  * The structure is string only
* A send mechanism that blocks until a recver ready to recv.
* A recv mechanism that blocks until a sender is ready to send.
* A sample mechanism that checks for a current sender, and returns the value if it exists, or continues execution.

** TODO: Add Examples, next things to expect, etc. **
