// https://adventofcode.com/2025/day/12

const std = @import("std");

const data = @embedFile("data/day12.txt");

const MAX_SHAPE_HEIGHT = 3;
const MAX_SHAPE_WIDTH = 3;

pub fn part1() u64 {
    var result: u64 = 0;
    // let's try a simple heuristic: is the available area larger than the max total shape area?

    // skip lines until we find the areas to process ie AxB: counts
    var line_it = std.mem.splitScalar(u8, data, '\n');
    while (line_it.peek()) |line| {
        if (std.mem.indexOfScalar(u8, line, 'x')) |_| {
            break;
        }
        _ = line_it.next();
    }

    while (line_it.next()) |line| {
        var tok_it = std.mem.tokenizeAny(u8, line, "x: ");
        const width_str = tok_it.next().?;
        const height_str = tok_it.next().?;
        const height = std.fmt.parseInt(u64, height_str, 10) catch unreachable;
        const width = std.fmt.parseInt(u64, width_str, 10) catch unreachable;

        var shape_count: u64 = 0;
        while (tok_it.next()) |count_str| {
            const num = std.fmt.parseInt(u64, count_str, 10) catch unreachable;
            shape_count += num;
        }

        const area = height * width;
        const max_shape_area = MAX_SHAPE_HEIGHT * MAX_SHAPE_WIDTH * shape_count;

        if (area >= max_shape_area) {
            result += 1;
        }
    }

    return result;
}
