const std = @import("std");
const print = std.debug.print;

const day1 = @import("day01.zig");

pub fn main() !void {
    print("day 1 part 1:\n{any}\n", .{day1.part1()});
    print("day 1 part 2:\n{any}\n", .{day1.part2()});
}
