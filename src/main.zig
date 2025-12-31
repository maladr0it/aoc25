const std = @import("std");
const day1 = @import("day01.zig");

const print = std.debug.print;

pub fn main() !void {
    print("day 1 part 1:\n{any}\n", .{day1.part1()});
}
