- [`cothread.unschedule`](#cothreadunschedule-)
- [`cothread.yield`](#cothreadyield-)
- [`cothread.next`](#cothreadnext-)
- [`cothread.after`](#cothreadafter-)
- [`cothread.plugin`](#cothreadplugin-)
- [`cothread.allready`](#cothreadallready-)
- [`cothread.isscheduled`](#cothreadisscheduled-)
- [`cothread.running`](#cothreadrunning-)

Index
=====

- [`cothread`](#cooperative-multithreading)
- [`cothread.schedule`](#cothreadschedule-)
- [`cothread.yield`](#cothreadyield-)
- [`cothread.suspend`](#cothreadsuspend-)
- [`cothread.step`](#cothreadstep-)
- [`cothread.run`](#cothreadrun-)
- [`cothread.requesthalt`](#cothreadrequesthalt-)
- [`cothread.cancelhalt`](#cothreadcancelhalt-)
- [`cothread.hasready`](#cothreadhasready-)

Contents
========

Cooperative Multithreading
--------------------------

This library provides functions for manipulation of a scheduler that resumes coroutines registered for execution.
It is designed to support cooperative multithreading.
A cooperative thread, or cothread for short, is a coroutine resumed by the scheduler.
Therefore, whenever a cothread yields the control goes back to the scheduler.
A cothread shall always yield a string indicating what the scheduler shall do with it.
The current options are:

- `"yield"`: the yielding thread is rescheduled, so it will be resumed later.

- `"suspend"`: the yielding thread is removed from the scheduler, so it will only be resumed if it is rescheduled.

### `thread = cothread.schedule (thread)`

Registers coroutine <code>thread</code> to be resumed by the scheduler.

### `cothread.concat (f, ...)`

Returns the values from the vararg `...` followed by all the values returned by call `f()`.

### `vararg.insert (v, i, ...)`

Returns the values from the vararg `...` with `v` inserted at position `i`, shifiting up the values from position `i`; `i` can be negative.
If, after the translation of a negative indice, `i` is greater than the number of values in the vararg, the returned values include all the values from the vararg followed by as many `nil` necessary to return `v` in position `i`.

### `vararg.len (...)`

Returns the number of values in the vararg `...`.

### `vararg.map (f, ...)`

Executes function `f` for each value in the vararg `...` and returns the equivalent of expression `f(v1),` ... `, f(vn)`, where values `v1`, ..., `vn` are the values in `...`.
If no additional parameters are provided (empty vararg), function `f` will not be executed and no values are returned.

### `vararg.pack (...)`

Returns a function that is a closure which captures all the values from the vararg `...` and can be used to inspect these values later.
The returned function can be called in three different ways to inspect the captured values:

#### `f ([i [, j]])`
Returns the captured values from position `i` until `j`, such as call [`vararg.range(i, j, ...)`](#varargrange-i-j) when `...` are the captured values.
If `i` and `j` are absent, they are assumed to be 1 and -1, respectively, thus all the captured values from the vararg are returned.
If only `j` is absent, then it is assumed to be equal to `i` (which indicates only the value at position shall be returned).

#### `f ("#")`
Returns the number of values captured.

#### `f (nil [, i])`
Returns the position and the value next to position `i`.
If `i` indicates the last value captured, then no values are returned.
If `i` is absent, it is assumed to be 0.
This usage pattern allow that the construction

```lua
for i, v in vararg.pack(...) do
	-- block
end
```

iterates over the captured values, where `i` is the position of the value, and `v` contains the captured value.

### `vararg.range (i, j, ...)`

Returns the values from the vararg `...` from position `i` until `j`; `i` and `j` can be negative.
If, after the translation of negative indices, `i` is less than 1, it is corrected to 1.
If `j` is greater than the number of values in the vararg, it is corrected to that number.
If, after these corrections, i is greater than j, the function returns no values.

### `vararg.remove (i, ...)`

Returns the values from the vararg `...` without value at position `i`, thus values after position `i` have the positions shifted down in the returned vararg; `i` can be negative.
If `i` does not indicate a position in the vararg, the same vararg is returned as the result.

### `vararg.replace (v, i, ...)`

Returns the values from the vararg `...` with `v` replacing the value at position `i`; `i` can be negative.
If, after the translation of a negative indice, `i` is greater than the number of values in the vararg, the returned values include all the values from the vararg followed by as many `nil` necessary to return `v` in position `i`.
