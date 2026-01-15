// https://adventofcode.com/2025/day/10

const std = @import("std");

const util = @import("util.zig");

// const data = @embedFile("data/x.txt");
const data = @embedFile("data/day10.txt");

const MAX_ROWS = 16;
const MAX_COLS = 16;

pub fn part1() u64 {
    var result: u64 = 0;

    // parse
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var mat: [MAX_ROWS][MAX_COLS]u1 = std.mem.zeroes([MAX_ROWS][MAX_COLS]u1); // add an extra col for the output
        var num_rows: usize = 0;
        var num_cols: usize = 0;

        {
            var i: usize = 0;
            while (i < line.len) : (i += 1) {
                switch (line[i]) {
                    '[' => {
                        i += 1;
                        while (line[i] != ']') : (i += 1) {
                            const val: u1 = switch (line[i]) {
                                '.' => 0,
                                '#' => 1,
                                else => unreachable,
                            };
                            mat[num_rows][0] = val; // add to the first column
                            num_rows += 1;
                        }
                        num_cols += 1; // output goes in the first column
                    },
                    '(' => {
                        i += 1;
                        const start = i;
                        while (line[i] != ')') : (i += 1) {} // get the length
                        var nums_it = std.mem.splitScalar(u8, line[start..i], ',');
                        while (nums_it.next()) |num_str| {
                            const light = std.fmt.parseInt(usize, num_str, 10) catch unreachable;
                            mat[light][num_cols] = 1;
                        }
                        num_cols += 1;
                    },
                    else => continue,
                }
            }
        }

        // we now do gaussian elimination
        var pivot_row: usize = 0;
        var is_pivot_col = [_]bool{false} ** MAX_COLS;
        var pivot_col_for_row: [MAX_ROWS]?usize = .{null} ** MAX_ROWS;

        // find and swap
        for (1..num_cols) |pivot_col| { // skip first col since it holds the output
            var found_row_opt: ?usize = null;
            for (pivot_row..num_rows) |row| {
                if (mat[row][pivot_col] != 0) {
                    found_row_opt = row;
                    break;
                }
            }

            const found_row = found_row_opt orelse continue;
            is_pivot_col[pivot_col] = true;
            pivot_col_for_row[pivot_row] = pivot_col;

            const tmp = mat[pivot_row];
            mat[pivot_row] = mat[found_row];
            mat[found_row] = tmp;

            // scale not needed, pivots are always 1 for this problem

            // eliminate
            for (0..num_rows) |row| {
                if (row != pivot_row and mat[row][pivot_col] != 0) {
                    for (0..num_cols) |col| {
                        // the buttons are toggles so pressing it twice cancels it out
                        // the result is the same as using mod(2), which is also the same as XORing
                        mat[row][col] ^= mat[pivot_row][col];
                    }
                    // assert
                    if (mat[row][pivot_col] != 0) {
                        unreachable;
                    }
                }
            }

            pivot_row += 1;
        }

        // find free variable columns
        var free_cols: [MAX_COLS]usize = undefined;
        var num_free_cols: usize = 0;
        for (1..num_cols) |col| {
            if (!is_pivot_col[col]) {
                free_cols[num_free_cols] = col;
                num_free_cols += 1;
            }
        }

        var min_presses: usize = std.math.maxInt(usize);

        // Try solving with all 2^num_free_cols combinations of free variables
        const num_combos = @as(usize, 1) << @intCast(num_free_cols);
        for (0..num_combos) |combo| {
            var solution = [_]u1{0} ** MAX_COLS;

            // Set free variables from combo bits
            for (0..num_free_cols) |i| {
                const col = free_cols[i];
                solution[col] = @intCast((combo >> @intCast(i)) & 1);
            }

            // solve for pivot variables
            for (0..num_rows) |row| {
                const pivot_col = pivot_col_for_row[row] orelse continue;
                var val: u1 = mat[row][0];
                for (1..num_cols) |col| {
                    if (col != pivot_col and mat[row][col] != 0) {
                        // subtracting from a toggle system just inverts it, so we use XOR
                        val ^= solution[col];
                    }
                }
                solution[pivot_col] = val;
            }

            var presses: usize = 0;
            for (1..num_cols) |col| {
                presses += solution[col];
            }
            min_presses = @min(min_presses, presses);
        }

        result += min_presses;
    }

    return result;
}

pub fn part2() u64 {
    return 0;
}
