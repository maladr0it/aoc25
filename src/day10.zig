// https://adventofcode.com/2025/day/10

const std = @import("std");

const util = @import("util.zig");

// const data = @embedFile("data/xx.txt");
const data = @embedFile("data/day10.txt");

const MAX_ROWS = 16;
const MAX_COLS = 16;

pub fn part1() u64 {
    var result: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var mat: [MAX_ROWS][MAX_COLS]u1 = std.mem.zeroes([MAX_ROWS][MAX_COLS]u1);
        var num_rows: usize = 0;
        var num_cols: usize = 0;

        // parse
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
                            const row_num = std.fmt.parseInt(usize, num_str, 10) catch unreachable;
                            mat[row_num][num_cols] = 1;
                        }
                        num_cols += 1;
                    },
                    else => continue,
                }
            }
        }

        var pivot_row: usize = 0;
        var is_pivot_col = [_]bool{false} ** MAX_COLS;
        var pivot_col_for_row: [MAX_ROWS]?usize = .{null} ** MAX_ROWS;

        for (1..num_cols) |pivot_col| { // skip first col since it holds the output
            // find and swap
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

        var min_presses: u64 = std.math.maxInt(u64);

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

            var presses: u64 = 0;
            for (1..num_cols) |col| {
                presses += solution[col];
            }
            min_presses = @min(presses, min_presses);
        }

        result += min_presses;
    }

    return result;
}

pub fn part2() f64 {
    var result: f64 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var mat = std.mem.zeroes([MAX_ROWS][MAX_COLS]f64);
        var num_rows: usize = 0;
        var num_cols: usize = 0;

        // parse
        {
            var i: usize = 0;
            while (i < line.len) : (i += 1) {
                switch (line[i]) {
                    '(' => {
                        i += 1;
                        const start = i;
                        while (line[i] != ')') : (i += 1) {} // get the length
                        var nums_it = std.mem.splitScalar(u8, line[start..i], ',');
                        while (nums_it.next()) |num_str| {
                            const row_num = std.fmt.parseInt(usize, num_str, 10) catch unreachable;
                            mat[row_num][num_cols] = 1;
                        }
                        num_cols += 1;
                    },
                    '{' => {
                        i += 1;
                        const start = i;
                        while (line[i] != '}') : (i += 1) {} // get the length
                        var nums_it = std.mem.splitScalar(u8, line[start..i], ',');
                        while (nums_it.next()) |num_str| {
                            const value = std.fmt.parseFloat(f64, num_str) catch unreachable;
                            mat[num_rows][num_cols] = value;
                            num_rows += 1;
                        }
                        num_cols += 1;
                    },
                    else => continue,
                }
            }
        }

        var pivot_row: usize = 0;
        var is_pivot_col = [_]bool{false} ** MAX_COLS;
        var pivot_col_for_row: [MAX_ROWS]?usize = .{null} ** MAX_ROWS;

        for (0..num_cols - 1) |pivot_col| { // skip the last col since it holds the output
            // find and swap
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

            // sacle
            const pivot_val = mat[pivot_row][pivot_col];
            for (0..num_cols) |col| {
                mat[pivot_row][col] /= pivot_val;
            }

            // for all other rows, eliminate the pivot column
            for (0..num_rows) |row| {
                if (row != pivot_row and mat[row][pivot_col] != 0) {
                    const factor = mat[row][pivot_col];
                    for (0..num_cols) |col| {
                        mat[row][col] -= factor * mat[pivot_row][col];
                    }
                }
            }

            pivot_row += 1;
        }

        // find free varaible columns
        var free_cols: [MAX_COLS]usize = undefined;
        var num_free_cols: usize = 0;
        for (0..num_cols - 1) |col| {
            if (!is_pivot_col[col]) {
                free_cols[num_free_cols] = col;
                num_free_cols += 1;
            }
        }

        // std.debug.print("free cols: {any}\n", .{num_free_cols});
        // if (num_free_cols >= 3) {
        //     // print the mat
        //     for (0..num_rows) |row| {
        //         for (0..num_cols) |col| {
        //             std.debug.print("{d} ", .{mat[row][col]});
        //         }
        //         std.debug.print("\n", .{});
        //     }
        // }

        // try for every combination of free variable, up to its upper bound
        //

        // use the total

        // find upper bounds for each free variable
        // var upper_bounds: [MAX_COLS]f64 = .{std.math.inf(f64)} ** MAX_COLS;
        // for (0..num_free_cols) |i| {
        //     const free_col = free_cols[i];

        //     for (0..num_rows) |row| {
        //         // If this button is the only one pressed, how many times can we press it
        //         // before we overshoot? That's result / coeff.
        //         // We take the min across all rows to get the tightest bound.
        //         const coeff = mat[row][free_col];
        //         if (coeff > 0) {
        //             const bound = mat[row][num_cols - 1] / coeff;
        //             if (bound >= 0) {
        //                 upper_bounds[i] = @min(bound, upper_bounds[i]);
        //             }
        //         }
        //     }

        //     // assert we got a bound
        //     if (upper_bounds[i] == std.math.inf(f64)) {
        //         upper_bounds[i] = 0;
        //         unreachable;
        //     }
        // }

        // find a safe upper-bound for the free variables
        const upper_bound = blk: {
            var sum_results: f64 = 0;
            for (0..num_rows) |row| {
                sum_results += @abs(mat[row][num_cols - 1]);
            }
            break :blk sum_results;
        };

        // try every combination of free variables
        var min_presses: f64 = std.math.inf(f64);
        var free_vals: [MAX_COLS]f64 = .{0} ** MAX_COLS;

        while (true) {
            // solve for pivot variables. they MUST be integer values
            var solution = [_]f64{0} ** MAX_COLS;

            for (0..num_free_cols) |i| {
                const free_col = free_cols[i];
                solution[free_col] = free_vals[i];
            }

            var valid = true;
            for (0..num_rows) |row| {
                const pivot_col = pivot_col_for_row[row] orelse continue;
                var pivot_val: f64 = mat[row][num_cols - 1];
                for (0..num_cols - 1) |col| {
                    if (col != pivot_col) {
                        pivot_val -= mat[row][col] * solution[col];
                    }
                }

                // check val is integer
                const epsilon = 0.001;
                if (pivot_val < -epsilon or @abs(pivot_val - @round(pivot_val)) > epsilon) {
                    valid = false;
                    break;
                }
                solution[pivot_col] = pivot_val;
            }

            if (valid) {
                var presses: f64 = 0;
                for (0..num_cols - 1) |col| {
                    presses += solution[col];
                }
                min_presses = @min(presses, min_presses);
            }

            // increment to next combination of numbers
            var carry = true;
            for (0..num_free_cols) |i| {
                if (!carry) {
                    break;
                }

                free_vals[i] += 1;
                if (free_vals[i] > upper_bound) {
                    free_vals[i] = 0;
                    carry = true;
                } else {
                    carry = false;
                }
            }
            if (carry) {
                break;
            }
        }

        // if (min_presses == std.math.inf(f64)) {
        //     // print the matrix and line number
        //     std.debug.print("matrix:\n", .{});
        //     for (0..num_rows) |row| {
        //         for (0..num_cols) |col| {
        //             std.debug.print("{d} ", .{mat[row][col]});
        //         }
        //         std.debug.print("\n", .{});
        //     }
        //     std.debug.print("line: {s}\n", .{line});
        // }

        result += min_presses;
    }

    return result;
}
