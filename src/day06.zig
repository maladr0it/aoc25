// https://adventofcode.com/2025/day/6

const std = @import("std");

const util = @import("util.zig");

const data = @embedFile("data/day06.txt");

fn isGap(grid: *util.Grid(u8), col: i32) bool {
    var row_it = grid.rowCoords();
    while (row_it.next()) |row| {
        if (grid.get(col, row) != ' ') {
            return false;
        }
    }
    return true;
}

pub fn part1() usize {
    var buf: [128 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    var grid = util.Grid(u8).initFromData(allocator, data) catch unreachable;

    var result: usize = 0;
    var col: i32 = 0;
    while (col < grid.width) {
        if (isGap(&grid, col)) {
            col += 1;
            continue;
        }

        const group_start = col;
        while (col < grid.width and !isGap(&grid, col)) {
            col += 1;
        }
        const group_end = col;

        const op = grid.get(group_start, grid.height - 1);
        var group_val: usize = 0;

        var digit_row: i32 = 0;
        // don't look at the last row, it's used for the operator
        while (digit_row < grid.height - 1) : (digit_row += 1) {
            var num: usize = 0;
            var digit_col = group_start;
            while (digit_col < group_end) : (digit_col += 1) {
                const char = grid.get(digit_col, digit_row);
                if (std.ascii.isDigit(char)) {
                    num = num * 10 + (char - '0');
                }
            }

            switch (op) {
                '+' => group_val = group_val + num,
                '*' => group_val = @max(group_val, 1) * num,
                else => unreachable,
            }
        }
        result += group_val;
    }

    return result;
}

pub fn part2() usize {
    var buf: [128 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    var grid = util.Grid(u8).initFromData(allocator, data) catch unreachable;

    var result: usize = 0;
    result = result;
    var col: i32 = 0;
    while (col < grid.width) {
        if (isGap(&grid, col)) {
            col += 1;
            continue;
        }

        const group_start = col;
        while (col < grid.width and !isGap(&grid, col)) {
            col += 1;
        }
        const group_end = col;

        const op = grid.get(group_start, grid.height - 1);
        var group_val: usize = 0;

        var digit_col: i32 = group_start;
        // we can read columns left to right since the only operations (+ / *) are associative
        while (digit_col < group_end) : (digit_col += 1) {
            var num: usize = 0;
            var digit_row: i32 = 0;
            // don't look at the last row, it's used for the operator
            while (digit_row < grid.height - 1) : (digit_row += 1) {
                const char = grid.get(digit_col, digit_row);
                if (std.ascii.isDigit(char)) {
                    num = num * 10 + (char - '0');
                }
            }

            switch (op) {
                '+' => group_val = group_val + num,
                '*' => group_val = @max(group_val, 1) * num,
                else => unreachable,
            }
        }
        result += group_val;
    }

    return result;
}
