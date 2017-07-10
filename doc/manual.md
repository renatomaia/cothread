- [`cothread.plugin`](#cothreadplugin-)
- [`cothread.running`](#cothreadrunning-)

Index
=====

- [`cothread`](#cooperative-multithreading)
- [`cothread.error`](#cothreaderror-)
- [`cothread.trap`](#cothreadtrap-)
- [`cothread.schedule`](#cothreadschedule-)
- [`cothread.unschedule`](#cothreadunschedule-)
- [`cothread.step`](#cothreadstep-)
- [`cothread.run`](#cothreadrun-)
- [`cothread.current`](#cothreadcurrent-)
- [`cothread.scheduled`](#cothreadscheduled-)
- [`cothread.iready`](#cothreadiready-)
- [`cothread.halt`](#cothreadhalt-)
- [`cothread.yield`](#cothreadyield-)
- [`cothread.suspend`](#cothreadsuspend-)

Contents
========

Cooperative Multithreading
--------------------------

This library provides functions for manipulation of coroutines scheduled for execution.

A coroutine scheduled to be resumed is called a cooperative thread, or cothread for short.
Cothreads are registered in queues.
However only cothreads in the *ready queue* are resumed.
Cothreds in other queues must be moved to the *ready queue* in order to be resumed.

Every cothread that is resumed produces values, as described below:

When the cothread terminates, the values returned by the body function are the values produced by the cothread.
When the cothread raises an error, the function in [`cothread.error`](#cothreaderror-) is called and the values returned by this function are the values produced by the cothread.
Alternatively, if in either case (termination or error) there is a function registered in [`cothread.trap`](#cothreadtrap-) for the cothread, then this function is called and the values returned are the values produced by the cothread.
Finally, when the cothread yields using one of the provided *yield operations* (described below), the extra values passed to yield operation are the values produced by the cothread.

**Note:** When a resumed cothread calls [`coroutine.yield`](http://www.lua.org/manual/5.3/manual.html#pdf-coroutine.yield) it shall provide a string indicating an *yield operation* with appropriate arguments, otherwise the cothread is treated as if it raised an error.

### `... = cothread.error (message)` 

Function that is called when a cothread which does not have a *trap function* (see [`cothread.trap`](#cothreadtrap-)) raises an error.
`message` is the error object.
All values returned by this function are the values produced by the cothread that raised the error.
By default this function is [`error`](http://www.lua.org/manual/5.3/manual.html#pdf-error).

### `cothread.trap [thead] = func` 

Table that maps cothread `thread` to its *trap function* `func`.
The *trap function* is called whenever the cothread terminates or raises an error while being resumed.
By default, this table is empty with a its own metatable that set it up with weak keys (`cotheads.trap = setmetatable({}, {__mode="k"})`).
The *trap function* is called as the following:

`... = func (thread, success, ...)`

Where `thread` is the dead cothread.
`success` is `true` if the cothread terminated, or `false` if it raised an error.
The additional arguments are the values returned by the cothread (when cothread terminates) or the error object if the cothread raised an error.
All values returned by the *trap function* are the values produced by the cothread.

### `success = cothread.schedule (thread [, when, ...])` 

Registers coroutine `thread` for execution if it is not registered already.
In such case the function returns `true`.
Otherwise it returns `false` and the function has no effect.
The value of `when` indicates a *scheduling operation* that defines how `thread` is registered.
The additional arguments are parameters of the *scheduling operation*.
The possible *scheduling operations* and their parameters are: (default is `"later"`)

- `"next"`: `thread` is inserted as the head of the *ready queue*.

- `"later"`: `thread` is added to the end of the *ready queue*.

- `"wait", signal`: `thread` is scheduled as if it has called *yielding operation* [`cothread.wait`](#cothreadwait-))`(signal)`.

- `"postpone", time`: `thread` is scheduled as if it has called *yielding operation* [`cothread.postpone`](#cothreadpostpone-))`(time)`.

- `"delay", seconds`: `thread` is scheduled as if it has called *yielding operation* [`cothread.delay`](#cothreaddelay-))`(seconds)`.

### `success = cothread.unschedule (thread)`

If `thread` is registered in one queue, it is removed from its current queue.
Therefore, it will not be resumed again unless it is rescheduled.
In this case this function returns `true`.
Otherwise, it returns `false` and the function has no effect.

### `... = cothread.step (...)`

If there are cothreads in the *ready queue*, it resumes the first one with the given arguments and returns the values produced by the cothread.
Otherwise it simply returns the given arguments and has no effect.

### `... = cothread.run (...)`

Resumes all threads in the *ready queue*, one after the oner, until there are no cothread in the queue (nor in the *postponed queue*), or one of the resumed cothread calls [`cothread.halt`](#cothreadhalt-).
The first cothread is resumed with the given arguments and the values it produces are passed to the next cothread and so on.
This function return the values produced by the last cothread resumed.
Alternatively, if no cothreads are resumed this function returns the given arguments and has no effect.

### `thread = cothread.current ()`

Returns the first cothread in the *ready queue* or `nil` if the queue is empty.

### `result = cothread.scheduled (thread)`

Returns `true` if `thread` is currently registered in some queue, or `false` otherwise.

### `for thread in cothread.iready () do ... end`

Returns a [`for`](http://www.lua.org/manual/5.3/manual.html#3.3.5) iterator that set as `thread` each cothread in the *ready queue*, from head to tail.

Yield Operations
----------------

Similar to standard function [`coroutine.yield`](http://www.lua.org/manual/5.3/manual.html#pdf-coroutine.yield), *yield operations* suspend the execution of the calling cothread.
However, they also tell how the cothread should be rescheduled.

*Yield operations* can take a fixed number of arguments.
All additional arguments beyond these become the values produced by the cothread.
So, is a *yield operation* named `foo` takes two arguments, then call `foo(a, b, c, d)` suspends the current cothread, and values `c` and `d` are the values produced by the cothread.

*Yield operations* can only be called from cothread resumed by operations [`cothread.step`](#cothreadstep-) or [`cothread.run`](#cothreadrun-).
Under the hood, they basically call [`coroutine.yield`](http://www.lua.org/manual/5.3/manual.html#pdf-coroutine.yield) with a string containing the name of the *yield operation* and the arguments passed.

### `... = cothread.halt (...)`

[*Yield operation*](#yield-operations) that keeps the current cothread as the head of the *ready queue*, so it will be the next cothread to be resumed.
Moreover, if the current cothread was resumed by a call to [`cothread.run`](#cothreadrun-), it makes such call return.
This *yield operation* takes no arguments.

### `... = cothread.yield (...)`

[*Yield operation*](#yield-operations) that reschedules the current cothread as the last cothread in the *ready queue*.
This *yield operation* takes no arguments.

### `... = cothread.suspend (...)`

[*Yield operation*](#yield-operations) that removes the current cothread from the scheduler, so it will not be resumed again unless it is rescheduled.
This *yield operation* takes no arguments.

Signal Support
--------------

### `... = cothread.wait (signal, ...)`

[*Yield operation*](#yield-operations) that takes a single argument `signal` and reschedules the cothread in the queue of value `signal` (see [`cothread.notify`](#cothreadnotify-))..

### `success = cothread.notify (signal [, when, ...])`

Reschedules all cothreads in queue of value `signal` using the *scheduler operation* defined by string `when` (default value is "later").
It is equivalent to call `cothread.unschedule(thread)` and `cothread.schedule(thread, when, ...)` for each cothread in the queue.
However, this operation takes constant time, no mater how many cothreads are in queue.
This function returns `true` if any cothread is rescheduled, or `false` otherwise.

### `signal = cothread.onall (...)`

Creates a special signal value that works as a combination of all the values given as arguments.
Whenever a cothread is scheduled in the queue identified by this signal, auxiliary cothreads are automatically scheduled in the queue of each of the combined values.
Whenever every one of these auxiliary cothreads are resumed, the cothreads in the queue of this signal are moved (rescheduled) to the end of the *ready queue*.
If the signal's queue becomes empty (cothreds are removed or moved to another queue) the auxiliary cothreads are automatically removed.

The returned value `signal` is a function that reschedules all auxiliary cothreads back to the queues of the combined values, if there are any cothreads registered in the signal's queue.
Therefore, you can call the signal to discard any previous notification of the combined values.

### `signal = cothread.onany (...)`

Creates a special signal value that works as a combination of any of the values given as arguments.
Whenever a cothread is scheduled in the queue identified by this signal, auxiliary cothreads are automatically scheduled in the queue of each of the combined values.
Whenever any one of these auxiliary cothreads are resumed, the cothreads in the queue of this signal are moved (rescheduled) to the end of the *ready queue*.
If the signal's queue becomes empty (cothreds are removed or moved to another queue) the auxiliary cothreads are automatically removed.

The returned value `signal` is a function that reschedules all auxiliary cothreads back to the queues of the combined values, if there are any cothreads registered in the signal's queue.
Therefore, you can call the signal to discard any previous notification of the combined values.

Time Support
------------

### `time = cothread.time ()`

Field with the function used by underlying scheduling system to to get a number indicating the current time in seconds.
The function in this field must never return a value smaller than a previously returned one (monotonically increasing in relation to the actual time).
By default this field contains a function that calculates time using standard functions [`os.time`](http://www.lua.org/manual/5.3/manual.html#pdf-os.time) and [`os.difftime`](http://www.lua.org/manual/5.3/manual.html#pdf-os.difftime).

### `cothread.idle (time)`

Field with the function called whenever the *ready queue* is empty but there are cothreads in the *postponed queue*.
Argument `time` indicates the value of the current time, as provided by function [`cothread.time`](#cothreadtime-), when the first cothread in the *postponed queue* must be rescheduled to the *ready queue*.
By default this field contains a function that repeatly calls [`cothread.time`](#cothreadtime-) until it returns a value greater or equal to `time` (*busy wait*).

### `... = cothread.postpone (time, ...)`

[*Yield operation*](#yield-operations) that takes a single argument `time` and reschedules the cothread to the *postponed queue* in such way that it will eventually be rescheduled to the *ready queue* after current time, as provided by function [`cothread.time`](#cothreadtime-), is the same or greater than `time`.

### `... = cothread.delay (seconds, ...)`

[*Yield operation*](#yield-operations) that takes a single argument `seconds` and is equivalent to `cothread.postpone(cothread.time()+seconds)`.
