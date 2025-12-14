const std = @import("std");
const io = std.io;
const os = std.os;
const printf = io.stdout.printf;

pub fn main() -> %void {
    var args_list = std.ArrayList(?%[]u8).init(&std.mem.c_allocator);
    defer args_list.deinit();
    var args = os.args();

populate:
    const to_append = args.next(&std.mem.c_allocator);
    if (to_append != null) {
        %%args_list.append(to_append);
        goto populate;
    }

    {var i: usize = 0; while (i < args_list.len) : (i += 1) {
        %%printf("Arg {}: {}\n", i, args_list.items[i]);
    }}

    // %%printf("Arg 0: {}\n", args.next(&std.mem.c_allocator));
    // %%printf("Arg 1: {}\n", args.next(&std.mem.c_allocator));
    // %%printf("Arg 2: {}\n", args.next(&std.mem.c_allocator));
    // %%printf("Arg 3: {}\n", args.next(&std.mem.c_allocator));
    // %%printf("Arg 4: {}\n", args.next(&std.mem.c_allocator));
}
