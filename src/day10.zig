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

pub fn part2() u64 {
    // Odd/even (bifurcation) approach, written in the same style as part 1:
    // - Build a u1 augmented matrix for the mod-2 system.
    // - Solve it with Gaussian elimination over GF(2).
    // - Try all parity (0/1) choices for the free variables.
    // - Subtract "press once" from the integer target, ensure it's even, halve, recurse.
    var result: u64 = 0;

    const Targets = [MAX_ROWS]i64;
    const Memo = std.AutoHashMap(Targets, u64);

    const Solver = struct {
        num_rows: usize,
        num_cols: usize, // total columns in the GF(2) augmented matrix (vars + rhs)
        affects: [MAX_ROWS][MAX_COLS]u1, // affects[row][button] = 1 if button affects row

        fn solve(self: *const @This(), memo: *Memo, targets_in: Targets) u64 {
            // zero out unused elements so it's a reliable hash key
            var targets = targets_in;
            for (self.num_rows..MAX_ROWS) |i| {
                targets[i] = 0;
            }

            if (memo.get(targets)) |cached| {
                return cached;
            }

            // base case
            var all_zero = true;
            for (0..self.num_rows) |i| {
                if (targets[i] != 0) {
                    all_zero = false;
                    break;
                }
            }
            if (all_zero) {
                memo.put(targets, 0) catch unreachable;
                return 0;
            }

            // Build augmented matrix for GF(2)
            const num_cols = self.num_cols;
            var gf2_mat: [MAX_ROWS][MAX_COLS]u1 = .{.{0} ** MAX_COLS} ** MAX_ROWS;
            for (0..self.num_rows) |row| {
                for (0..num_cols - 1) |btn| {
                    gf2_mat[row][btn] = self.affects[row][btn];
                }
                gf2_mat[row][num_cols - 1] = @intCast(targets[row] & 1);
            }

            var pivot_row: usize = 0;
            var is_pivot_col = [_]bool{false} ** MAX_COLS;
            var pivot_col_for_row: [MAX_ROWS]?usize = .{null} ** MAX_ROWS;

            for (0..num_cols - 1) |pivot_col| {
                // find and swap
                var found_row_opt: ?usize = null;
                for (pivot_row..self.num_rows) |row| {
                    if (gf2_mat[row][pivot_col] != 0) {
                        found_row_opt = row;
                        break;
                    }
                }

                const found_row = found_row_opt orelse continue;
                is_pivot_col[pivot_col] = true;
                pivot_col_for_row[pivot_row] = pivot_col;

                const tmp = gf2_mat[pivot_row];
                gf2_mat[pivot_row] = gf2_mat[found_row];
                gf2_mat[found_row] = tmp;

                // eliminate
                for (0..self.num_rows) |row| {
                    if (row != pivot_row and gf2_mat[row][pivot_col] != 0) {
                        for (0..num_cols) |col| {
                            gf2_mat[row][col] ^= gf2_mat[pivot_row][col];
                        }
                    }
                }

                pivot_row += 1;
            }

            // check if no solution (0 = 1)
            for (0..self.num_rows) |row| {
                var all_zero_cols = true;
                for (0..num_cols - 1) |col| {
                    if (gf2_mat[row][col] != 0) {
                        all_zero_cols = false;
                        break;
                    }
                }
                if (all_zero_cols and gf2_mat[row][num_cols - 1] != 0) {
                    memo.put(targets, std.math.maxInt(u64)) catch unreachable;
                    return std.math.maxInt(u64);
                }
            }

            // find free columns
            var free_cols: [MAX_COLS]usize = undefined;
            var num_free: usize = 0;
            for (0..num_cols - 1) |col| {
                if (!is_pivot_col[col]) {
                    free_cols[num_free] = col;
                    num_free += 1;
                }
            }

            var best: u64 = std.math.maxInt(u64);
            const combos: usize = @as(usize, 1) << @intCast(num_free);

            for (0..combos) |combo| {
                var odd_presses = [_]u1{0} ** MAX_COLS;

                // set free vars from combo bits
                for (0..num_free) |i| {
                    const col = free_cols[i];
                    odd_presses[col] = @intCast((combo >> @intCast(i)) & 1);
                }

                // solve pivot vars
                for (0..self.num_rows) |row| {
                    const pivot_col = pivot_col_for_row[row] orelse continue;
                    var val: u1 = gf2_mat[row][num_cols - 1];
                    for (0..num_cols - 1) |col| {
                        if (col != pivot_col and gf2_mat[row][col] != 0) {
                            val ^= odd_presses[col];
                        }
                    }
                    odd_presses[pivot_col] = val;
                }

                var next_targets: Targets = .{0} ** MAX_ROWS;
                var ok = true;
                for (0..self.num_rows) |r| {
                    var pressed_once_effect: i64 = 0;
                    for (0..num_cols - 1) |btn| {
                        if (odd_presses[btn] != 0 and self.affects[r][btn] != 0) {
                            pressed_once_effect += 1;
                        }
                    }

                    const remaining = targets[r] - pressed_once_effect;
                    if (remaining < 0 or (remaining & 1) != 0) {
                        ok = false;
                        break;
                    }
                    next_targets[r] = @divExact(remaining, 2);
                }
                if (!ok) {
                    continue;
                }

                const sub = self.solve(memo, next_targets);
                if (sub == std.math.maxInt(u64)) {
                    continue;
                }

                var cost_this: u64 = 0;
                for (0..num_cols - 1) |btn| {
                    cost_this += odd_presses[btn];
                }

                best = @min(best, cost_this + 2 * sub);
            }

            memo.put(targets, best) catch unreachable;
            return best;
        }
    };

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var affects: [MAX_ROWS][MAX_COLS]u1 = .{.{0} ** MAX_COLS} ** MAX_ROWS;
        var targets: Targets = .{0} ** MAX_ROWS;
        var num_rows: usize = 0;
        var num_cols: usize = 0; // counts variables while parsing, then +1 for rhs

        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            switch (line[i]) {
                '(' => {
                    i += 1;
                    const start = i;
                    while (line[i] != ')') : (i += 1) {}
                    var nums_it = std.mem.splitScalar(u8, line[start..i], ',');
                    while (nums_it.next()) |num_str| {
                        const row_num = std.fmt.parseInt(usize, num_str, 10) catch unreachable;
                        affects[row_num][num_cols] = 1;
                    }
                    num_cols += 1;
                },
                '{' => {
                    i += 1;
                    const start = i;
                    while (line[i] != '}') : (i += 1) {}
                    var nums_it = std.mem.splitScalar(u8, line[start..i], ',');
                    while (nums_it.next()) |num_str| {
                        targets[num_rows] = std.fmt.parseInt(i64, num_str, 10) catch unreachable;
                        num_rows += 1;
                    }
                    num_cols += 1;
                },
                else => continue,
            }
        }

        var memo = Memo.init(std.heap.page_allocator);
        defer memo.deinit();

        const solver = Solver{ .num_rows = num_rows, .num_cols = num_cols, .affects = affects };
        result += solver.solve(&memo, targets);
    }

    return result;
}
