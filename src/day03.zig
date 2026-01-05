// https://adventofcode.com/2025/day/3

const std = @import("std");

const data = @embedFile("data/day03.txt");

fn get_best_joltage(bank: []const u8, num_batts: usize) usize {
    var bank_joltage: usize = 0;
    var prev_best_batt_pos: usize = 0;

    // assert
    if (num_batts > bank.len) {
        unreachable;
    }

    for (0..num_batts) |i| {
        // batt_pos is -num_batts + i from the end to make room for the later batts
        // batt_pos is 1-indexed so we don't underflow when iterating backward
        var batt_pos: usize = bank.len - num_batts + i + 1;
        var best_batt_pos: usize = 0;
        var best_batt_value: u8 = 0;

        // find the leftmost battery with the highest value
        while (batt_pos > prev_best_batt_pos) {
            const batt_value = bank[batt_pos - 1] - '0'; // bank is 0 indexed, so minus 1
            if (batt_value >= best_batt_value) {
                best_batt_value = batt_value;
                best_batt_pos = batt_pos;
            }
            batt_pos -= 1;
        }

        bank_joltage = bank_joltage * 10 + best_batt_value;
        prev_best_batt_pos = best_batt_pos;
    }

    return bank_joltage;
}

pub fn part1() usize {
    var result: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        result += get_best_joltage(line, 2);
    }

    return result;
}

pub fn part2() usize {
    var result: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        result += get_best_joltage(line, 12);
    }

    return result;
}
