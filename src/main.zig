const std = @import("std");
const print = std.debug.print;

const day1 = @import("day01.zig");
const day2 = @import("day02.zig");

pub fn main() !void {
    if (false) {
        print("Day 01 Part 1: {d}\n", .{day1.part1()});
        print("Day 01 Part 2: {d}\n", .{day1.part2()});
    }

    print("Day 02 Part 1: {d}\n", .{day2.part1()});
    print("Day 02 Part 2: {d}\n", .{day2.part2()});
}
