const std = @import("std");
const print = std.debug.print;

const day1 = @import("day01.zig");
const day2 = @import("day02.zig");
const day3 = @import("day03.zig");
const day4 = @import("day04.zig");

var timer: std.time.Timer = undefined;

pub fn start_timer() void {
    timer = std.time.Timer.start() catch unreachable;
}

pub fn stop_timer() void {
    const elapsed = timer.lap();
    const ms = @as(f64, @floatFromInt(elapsed)) / 1_000_000.0;
    std.debug.print("elapsed: ({d:.3}ms)\n", .{ms});
}

pub fn main() !void {
    start_timer();
    if (true) {
        print("Day 01 Part 1: {d}\n", .{day1.part1()}); // 1132
        print("Day 01 Part 2: {d}\n", .{day1.part2()}); // 6623
        print("Day 02 Part 1: {d}\n", .{day2.part1()}); // 31000881061
        print("Day 02 Part 2: {d}\n", .{day2.part2()}); // CLEAN THIS ONE UP 46769308485
        print("Day 03 Part 1: {d}\n", .{day3.part1()}); // 17107
        print("Day 03 Part 1: {d}\n", .{day3.part2()}); // 169349762274117

    }
    print("Day 04 Part 1: {d}\n", .{day4.part1()}); // 1495
    print("Day 04 Part 2: {d}\n", .{day4.part2()}); // 8768

    stop_timer();
}
