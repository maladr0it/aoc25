const std = @import("std");

// const data = @embedFile("data/x.txt");

const data = @embedFile("data/day05.txt");

pub fn part1() usize {
    const MAX_RANGES = 256;
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

    // TODO: we can probably consolidate/flattenn these ranges somehow so we dont need to iterate over all of them

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
    return 0;
}
