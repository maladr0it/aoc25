// https://adventofcode.com/2025/day/9

const std = @import("std");

const util = @import("util.zig");

const data = @embedFile("data/x.txt");
// const data = @embedFile("data/day09.txt");

const MAX_POINTS = 512;

pub fn part1() u64 {
    var buf: [MAX_POINTS][2]i64 = undefined;
    var points = std.ArrayList([2]i64).initBuffer(&buf);

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var parts = std.mem.splitScalar(u8, line, ',');
        const x_str = parts.next().?;
        const y_str = parts.next().?;
        const x = std.fmt.parseInt(i64, x_str, 10) catch unreachable;
        const y = std.fmt.parseInt(i64, y_str, 10) catch unreachable;
        points.appendAssumeCapacity(.{ x, y });
    }

    var max_area: u64 = 0;

    for (0..points.items.len) |i| {
        const point_a = points.items[i];
        for (i + 1..points.items.len) |j| {
            const point_b = points.items[j];
            const area = @abs((point_a[0] - point_b[0] + 1) * (point_a[1] - point_b[1] + 1));
            max_area = @max(area, max_area);
        }
    }

    return max_area;
}

pub fn part2() usize {
    return 0;
}
