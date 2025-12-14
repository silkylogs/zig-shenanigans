const io = @import("std").io;
const os = @import("std").os;
const mem = @import("std").mem;
const ArrayList = @import("std").ArrayList;

fn getOsArgs() -> ArrayList(?%[]u8) {
    var args_list = ArrayList(?%[]u8).init(&mem.c_allocator);
    var args = os.args();

populate:
    const to_append = args.next(&mem.c_allocator); // Zig\std\os\index.zig:1377: "You must free the returned memory when done."
    if (to_append != null) {
        %%args_list.append(to_append);
        // to_append.free();
        goto populate;
    }
    // to_append.free();

    return args_list;
}


// error declaration, makes `error.ArgNotFound` available
error ArgNotFound;

pub fn main() -> %void {
    // integers
    const one_plus_one: i32 = 1 + 1;
    %%io.stdout.printf("1 + 1 = {}\n", one_plus_one);

    // floats
    const seven_div_three: f32 = 7.0 / 3.0;
    %%io.stdout.printf("7.0 / 3.0 = {}\n", seven_div_three);

    // boolean
    %%io.stdout.printf("{}\n{}\n{}\n",
        true and false,
        true or false,
        !true);

    // nullable
    const os_args = getOsArgs();

    const nullable_value = if (os_args.len >= 2) os_args.items[1] else null;
    %%io.stdout.printf("\nnullable\ntype: {}\nvalue: {}\n",
        @typeName(@typeOf(nullable_value)), nullable_value);

    // error union
    const number_or_error = if (os_args.len >= 3) os_args.items[2] else error.ArgNotFound;
    %%io.stdout.printf("\nerror union\ntype: {}\nvalue: {}\n",
        @typeName(@typeOf(number_or_error)), number_or_error);
}
