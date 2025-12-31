// https://adventofcode.com/2025/day/1

const std = @import("std");

// const data = @embedFile("data/x.txt");
const data = @embedFile("data/day01.txt");

const START_POS = 50;
const VALUES_COUNT = 100;

pub fn part1() usize {
    var zero_count: usize = 0;
    var pos: i16 = START_POS;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const dir = line[0];
        const num_steps = std.fmt.parseInt(i16, line[1..], 10) catch unreachable;

        const delta = switch (dir) {
            'L' => -num_steps,
            'R' => num_steps,
            else => unreachable,
        };

        pos = @mod(pos + delta, VALUES_COUNT);

        if (pos == 0) {
            zero_count += 1;
        }
    }

    return zero_count;
}
