# TODO:

- Add more tests.

### ADR:

- Was thinking of checking if the generic is a pointer to some struct and the given struct has a deinit/some sort of destructor in order to free the memory, but I guess the user can do that once it dequeues the item - I mean either way the pointer is considered "death" from the view point of the circular array and will be replaced by another one. I think the use should decide when to handle releasing the memory, which is much better experience IMO. In scenarios where low latency isn't a concern the user could always deinit after the dequeue, in scenarios where latency is a factor the user could keep track of dequeued pointers and decide when to free them at bulk - simulating garbage collection(and if to release them at all for that matter, if growing memory isn't a concern).
