// https://adventofcode.com/2025/day/2

const std = @import("std");

const data = @embedFile("data/day02.txt");

fn sum_echo_pair_numbers(to: usize) usize {
    // numbers made from 2 repeating sequences are just the base number added with itself times a magnitude
    // e.g. 1111 is 11 + 100 * 11, ie 11 * 101
    var sum: usize = 0;
    var period: u8 = 1; // number of digits in the repeated (base) sequence

    while (true) {
        const multiplier = std.math.pow(usize, 10, period) + 1;

        const base_min = std.math.pow(usize, 10, period - 1);
        const base_max = @min(
            std.math.pow(usize, 10, period) - 1,
            (to -| 1) / multiplier, // minus 1 since the range is exclusive
        );

        if (base_min > base_max) {
            break;
        }

        const count = base_max - base_min + 1;
        const base_sum = count * (base_min + base_max) / 2;

        sum += multiplier * base_sum;
        period += 1;
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
    const MAX_ECHO_NUMS = 1024;

    var buf: [64 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    var echo_nums = std.AutoHashMap(usize, void).init(allocator);
    echo_nums.ensureTotalCapacity(MAX_ECHO_NUMS) catch unreachable;

    var sum: usize = 0;

    var ranges = std.mem.splitScalar(u8, data, ',');
    while (ranges.next()) |range| {
        var parts = std.mem.splitScalar(u8, range, '-');
        const start_str = parts.next().?;
        const end_str = parts.next().?;
        const start = std.fmt.parseInt(usize, start_str, 10) catch unreachable;
        const end = std.fmt.parseInt(usize, end_str, 10) catch unreachable;

        echo_nums.clearRetainingCapacity();

        var period: u8 = 1; // digits in base
        while (true) {
            const ten_pow_period = std.math.pow(usize, 10, period); // 10^period
            const base_min = std.math.pow(usize, 10, period - 1);
            const base_max = ten_pow_period - 1;

            const min_echo_num = base_min * (ten_pow_period + 1);
            if (min_echo_num > end) {
                break;
            }

            for (base_min..base_max + 1) |base| {
                var multiplier: usize = ten_pow_period + 1; // two repeats
                var echo_num: usize = base * multiplier;

                while (echo_num <= end) {
                    if (echo_num >= start) {
                        echo_nums.put(echo_num, {}) catch unreachable;
                    }

                    multiplier = multiplier * ten_pow_period + 1;
                    echo_num = base * multiplier;
                }
            }

            period += 1;
        }

        var echo_it = echo_nums.keyIterator();
        while (echo_it.next()) |echo_num_ptr| {
            sum += echo_num_ptr.*;
        }
    }

    return sum;
}
