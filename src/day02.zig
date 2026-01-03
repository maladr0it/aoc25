// https://adventofcode.com/2025/day/2

const std = @import("std");

const data = @embedFile("data/day02.txt");

fn sum_echo_pair_numbers(to: usize) usize {
    // numbers made from 2 repeating sequences are just the sequence added with itself times a magnitude
    // e.g. 1111 is 11 + 100 * 11, ie 11 * 101
    var sum: usize = 0;
    var k: u8 = 1; // number of digits in the echoed sequence

    while (true) {
        const multiplier = std.math.pow(usize, 10, k) + 1;

        const sequence_min = std.math.pow(usize, 10, k - 1);
        const sequence_max = @min(
            std.math.pow(usize, 10, k) - 1,
            (to -| 1) / multiplier, // minus 1 since the range is exclusive
        );

        if (sequence_min > sequence_max) {
            break;
        }

        const count = sequence_max - sequence_min + 1;
        const sequence_sum = count * (sequence_min + sequence_max) / 2;

        sum += multiplier * sequence_sum;
        k += 1;
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

        sum += (sum_echo_pair_numbers(end + 1) - sum_echo_pair_numbers(start));
    }

    return sum;
}

pub fn part2() usize {
    const MAX_DIGITS = 16;

    var sum: usize = 0;

    var ranges = std.mem.splitScalar(u8, data, ',');
    while (ranges.next()) |range| {
        var parts = std.mem.splitScalar(u8, range, '-');
        const start_str = parts.next().?;
        const end_str = parts.next().?;
        const start = std.fmt.parseInt(usize, start_str, 10) catch unreachable;
        const end = std.fmt.parseInt(usize, end_str, 10) catch unreachable;

        var digits_buf: [MAX_DIGITS * 2]u8 = undefined;
        digits_buf = digits_buf; // autofix

        for (start..end + 1) |i| {
            const digits = std.fmt.bufPrint(&digits_buf, "{d}", .{i}) catch unreachable;

            // echo isn't possible with less than 2 digits
            if (digits.len < 2) {
                continue;
            }

            // repeat the digits, then remove the first and last digits
            // if these trimmed digits still contain the original digits, it's an echo number
            const copy_dest = digits_buf[digits.len .. digits.len * 2];
            @memcpy(copy_dest, digits);
            const trimmed = digits_buf[1 .. digits.len * 2 - 1];
            if (std.mem.indexOf(u8, trimmed, digits) != null) {
                sum += i;
            }
        }
    }

    return sum;
}
