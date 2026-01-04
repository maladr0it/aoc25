// https://adventofcode.com/2025/day/3

const std = @import("std");

// const data = @embedFile("data/x.txt");
const data = @embedFile("data/day03.txt");

pub fn part1() usize {
    const NUM_BATTS = 2;
    var result: usize = 0;

    var banks = std.mem.tokenizeScalar(u8, data, '\n');
    while (banks.next()) |line| {
        var bank_joltage: usize = 0;
        var prev_best_batt_pos: usize = 0;

        for (0..NUM_BATTS) |i| {
            // batt_pos is -NUM_BATTS + i from the end to make room for the later batts
            // batt_pos is 1-indexed so we don't underflow when iterating backward
            var batt_pos: usize = line.len - NUM_BATTS + i + 1; 
            var best_batt_pos: usize = 0;
            var best_batt_value: u8 = 0;

            // find the leftmost battery with the highest value
            while (batt_pos > prev_best_batt_pos) {
                const batt_value = line[batt_pos - 1] - '0';  // line is 0 indexed, so minus 1
                if (batt_value >= best_batt_value) {
                    best_batt_value = batt_value;
                    best_batt_pos = batt_pos;
                }
                batt_pos -= 1;
            }

            bank_joltage = bank_joltage * 10 + best_batt_value;
            prev_best_batt_pos = best_batt_pos;

        }

        result += bank_joltage;
    }


    return result;
}
