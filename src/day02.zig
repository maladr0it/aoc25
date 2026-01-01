// https://adventofcode.com/2025/day/2

const std = @import("std");

// const data = @embedFile("data/x.txt");
const data = @embedFile("data/day02.txt");

fn sum_echo_numbers(to: usize) usize {
    // numbers made from 2 repeating sequences are just the sequence added with itself times a magnitude
    // e.g. 1111 is 11 + 100 * 11, ie 11 * 101
    var sum: usize = 0;
    var sequence_digit_count: u8 = 1;

    while (true) {
        const multiplier = std.math.pow(usize, 10, sequence_digit_count) + 1;

        const sequence_min = std.math.pow(usize, 10, sequence_digit_count - 1);
        const sequence_max = @min(
            std.math.pow(usize, 10, sequence_digit_count) - 1,
            (to -| 1) / multiplier, // minus 1 since the range is exclusive
        );

        if (sequence_min > sequence_max) {
            break;
        }

        const count = sequence_max - sequence_min + 1;
        const sequence_sum = count * (sequence_min + sequence_max) / 2;

        sum += multiplier * sequence_sum;
        sequence_digit_count += 1;
    }

    return sum;
}

pub fn part1() usize {
    var sum: usize = 0;

    var ranges = std.mem.splitScalar(u8, data, ',');
    while (ranges.next()) |range| {
        var parts = std.mem.splitScalar(u8, range, '-');
        const start_str = parts.next() orelse unreachable;
        const end_str = parts.next() orelse unreachable;
        const start = std.fmt.parseInt(usize, start_str, 10) catch unreachable;
        const end = std.fmt.parseInt(usize, end_str, 10) catch unreachable;

        sum += (sum_echo_numbers(end + 1) - sum_echo_numbers(start));
    }

    return sum;
}

pub fn part2() usize {
    return 0;
}
