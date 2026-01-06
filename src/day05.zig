const std = @import("std");

const data = @embedFile("data/day05.txt");

const MAX_RANGES = 256;

pub fn part1() usize {
    var ranges_buf: [MAX_RANGES][2]usize = undefined;
    var ranges = std.ArrayList([2]usize).initBuffer(&ranges_buf);

    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var parts = std.mem.splitScalar(u8, line, '-');
        const start_str = parts.next().?;
        const end_str = parts.next().?;
        const start = std.fmt.parseInt(usize, start_str, 10) catch unreachable;
        const end = std.fmt.parseInt(usize, end_str, 10) catch unreachable;

        ranges.appendAssumeCapacity(.{ start, end });
    }

    var result: usize = 0;

    while (lines.next()) |line| {
        const num = std.fmt.parseInt(usize, line, 10) catch unreachable;
        for (ranges.items) |range| {
            if (num >= range[0] and num <= range[1]) {
                result += 1;
                break;
            }
        }
    }

    return result;
}

pub fn part2() usize {
    var ranges_buf: [MAX_RANGES][2]usize = undefined;
    var ranges = std.ArrayList([2]usize).initBuffer(&ranges_buf);

    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var parts = std.mem.splitScalar(u8, line, '-');
        const start_str = parts.next().?;
        const end_str = parts.next().?;
        const start = std.fmt.parseInt(usize, start_str, 10) catch unreachable;
        const end = std.fmt.parseInt(usize, end_str, 10) catch unreachable;

        ranges.appendAssumeCapacity(.{ start, end });
    }

    std.mem.sort([2]usize, ranges.items, {}, struct {
        fn lessThan(_: void, a: [2]usize, b: [2]usize) bool {
            return a[0] < b[0];
        }
    }.lessThan);

    var cur_range_start: usize = 0;
    var cur_range_end: usize = 0; // exclusive
    var total_span: usize = 0;

    for (ranges.items) |range| {
        if (range[0] > cur_range_end) {
            // no overlap/adjacency - end the current range and start a new one
            total_span += (cur_range_end - cur_range_start);
            cur_range_start = range[0];
        }
        cur_range_end = range[1] + 1; // add one since ranges are inclusive
    }

    // end the final range
    total_span += (cur_range_end - cur_range_start);

    return total_span;
}
