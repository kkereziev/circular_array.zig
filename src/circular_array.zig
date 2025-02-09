const std = @import("std");

pub fn CircularArray(comptime T: type) type {
    return struct {
        const Self = @This();

        _alloc: std.mem.Allocator,
        _buf: []T,
        _head: usize,
        _tail: usize,
        _size: usize,

        pub fn init(alloc: std.mem.Allocator, initialSize: usize) !Self {
            const buf = try alloc.alloc(T, initialSize);

            return .{
                ._alloc = alloc,
                ._buf = buf,
                ._head = 0,
                ._tail = 0,
                ._size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self._alloc.free(self._buf);
        }

        pub fn size(self: *Self) usize {
            return self._size;
        }

        pub fn enqueue(self: *Self, elem: T) !void {
            if (!self.hasCapacity()) {
                try self.resize(self._buf.len * 2);
            }

            self._buf[self._tail] = elem;

            self._tail += 1;
            self._size += 1;

            if (self._tail == self._buf.len) {
                self._tail = 0;
            }
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.size() == 0) {
                return null;
            }

            const val = self._buf[self._head];
            self._head += 1;
            self._size -= 1;

            if (self._head == self._buf.len) {
                self._head = 0;
            }

            return val;
        }

        pub fn peek(self: *Self) ?T {
            if (self.size() == 0) {
                return null;
            }

            return self._buf[self._head];
        }

        pub fn peekLast(self: *Self) ?T {
            if (self.size() == 0) {
                return null;
            }

            return self._buf[self._tail];
        }

        fn resize(self: *Self, new_size: usize) !void {
            const newArr = try self._alloc.alloc(T, new_size);

            var ind: usize = 0;
            var sourceIndx = self._head;

            while (ind < self.size()) {
                if (sourceIndx == self._buf.len) {
                    sourceIndx = 0;
                }

                newArr[ind] = self._buf[sourceIndx];

                sourceIndx += 1;
                ind += 1;
            }

            self._head = 0;
            self._tail = self._buf.len;

            self._alloc.free(self._buf);
            self._buf = newArr;
        }

        fn hasCapacity(self: *Self) bool {
            return self.size() != self._buf.len;
        }
    };
}

test {
    std.testing.refAllDecls(@This());
}

test "enqueue" {
    var arr = try CircularArray(usize).init(std.testing.allocator, 20);
    defer arr.deinit();

    try arr.enqueue(32);

    std.debug.assert(arr.size() == 1);
    std.debug.assert(arr._head == 0);
    std.debug.assert(arr._tail == 1);
}

test "dequeue" {
    var arr = try CircularArray(usize).init(std.testing.allocator, 20);
    defer arr.deinit();

    try arr.enqueue(32);
    const res = arr.dequeue();

    std.debug.assert(arr.size() == 0);
    std.debug.assert(arr._head == 1);
    std.debug.assert(arr._tail == 1);
    std.debug.assert(res != null);
}

test "enqueue after dequeue" {
    var arr = try CircularArray(usize).init(std.testing.allocator, 20);
    defer arr.deinit();

    try arr.enqueue(32);
    _ = arr.dequeue();
    try arr.enqueue(10);

    std.debug.assert(arr.size() == 1);
    std.debug.assert(arr._head == 1);
    std.debug.assert(arr._tail == 2);
}
