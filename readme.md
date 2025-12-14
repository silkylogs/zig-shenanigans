# Zig shennanigans, 0.1.1 edition

## Command line arguments in Zig 0.1.1
Build instructions: Run build.bat in the VS2022 developer command prompt.  
TODO: tell a story

## Example: Values
I feel kinda good about myself finding a fix for a broken doc example. This one in particular:
```rs
const io = @import("std").io;
const os = @import("std").os;

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
    const nullable_value = if (os.args.count() >= 2) os.args.at(1) else null;
    %%io.stdout.printf("\nnullable\ntype: {}\nvalue: {}\n",
        @typeName(@typeOf(nullable_value)), nullable_value);

    // error union
    const number_or_error = if (os.args.count() >= 3) os.args.at(2) else error.ArgNotFound;
    %%io.stdout.printf("\nerror union\ntype: {}\nvalue: {}\n",
        @typeName(@typeOf(number_or_error)), number_or_error);
}
```
The problem was that the creator forgot to take into consideration that the api for os.args was updated. So, compiling this as-is got me this error:
```go
error: type 'fn() -> ArgIterator' does not support field access
    const nullable_value = if (os.args.count() >= 2) os_args.items[1] else null;
                                      ^
```
The problem was that the new API did not have any way to access arguments directly. You're only given a linear iterator, and that's it.
```rs
pub const ArgIterator = struct {
    inner: if (builtin.os == Os.windows) ArgIteratorWindows else ArgIteratorPosix,

    pub fn init() -> ArgIterator {...}
    
    /// You must free the returned memory when done.
    pub fn next(self: &ArgIterator, allocator: &Allocator) -> ?%[]u8 {...}

    /// If you only are targeting posix you can call this and not need an allocator.
    pub fn nextPosix(self: &ArgIterator) -> ?[]const u8 {...}

    /// Parse past 1 argument without capturing it.
    /// Returns `true` if skipped an arg, `false` if we are at the end.
    pub fn skip(self: &ArgIterator) -> bool {...}
};
```
So, the only solution I could think about was to iterate through the arguments and copy it into an ArrayList so I could have random access to them:
```rs
fn getOsArgs() -> ArrayList(?%[]u8) {
    var args_list = ArrayList(?%[]u8).init(&mem.c_allocator);
    var args = os.args();

populate:
    // Zig\std\os\index.zig:1377: "args.next(): You must free the returned memory when done."
    // But.. how? Not my problem for now.
    const to_append = args.next(&mem.c_allocator);
    if (to_append != null) {
        %%args_list.append(to_append);
        // to_append.free();
        goto populate;
    }
    // to_append.free();

    return args_list;
}
```
And update the usage code:
```rs
    // nullable
    const os_args = getOsArgs();
    const nullable_value = if (os_args.len >= 2) os_args.items[1] else null;
    %%io.stdout.printf("\nnullable\ntype: {}\nvalue: {}\n",
        @typeName(@typeOf(nullable_value)), nullable_value);

    // error union
    const number_or_error = if (os_args.len >= 3) os_args.items[2] else error.ArgNotFound;
    %%io.stdout.printf("\nerror union\ntype: {}\nvalue: {}\n",
        @typeName(@typeOf(number_or_error)), number_or_error);
```
The results are same as in the docs. Yipee!