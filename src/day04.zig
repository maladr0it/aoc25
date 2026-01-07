const std = @import("std");

const util = @import("util.zig");

const data = @embedFile("data/day04.txt");

const ADJ_OFFSETS = [_][2]i32{
    .{ -1, -1 },
    .{ 0, -1 },
    .{ 1, -1 },
    .{ -1, 0 },
    .{ 1, 0 },
    .{ -1, 1 },
    .{ 0, 1 },
    .{ 1, 1 },
};

pub fn part1() usize {
    var grid = util.Grid(u8).initFromData(std.heap.page_allocator, data) catch unreachable;
    var result: usize = 0;

    var coords_it = grid.coords();
    while (coords_it.next()) |coord| {
        const x = coord[0];
        const y = coord[1];

        if (grid.get(x, y) != '@') {
            continue;
        }

        var adj_roll_count: u8 = 0;
        for (ADJ_OFFSETS) |offset| {
            if (grid.getSafe(x + offset[0], y + offset[1])) |val| {
                if (val == '@') {
                    adj_roll_count += 1;
                }
            }
        }

        if (adj_roll_count < 4) {
            result += 1;
        }
    }

    return result;
}

pub fn part2() usize {
    var grid = util.Grid(u8).initFromData(std.heap.page_allocator, data) catch unreachable;

    var result: usize = 0;

    while (true) {
        var rolls_removed: usize = 0;

        var coords_it = grid.coords();
        while (coords_it.next()) |coord| {
            const x = coord[0];
            const y = coord[1];

            if (grid.get(x, y) != '@') {
                continue;
            }

            var adj_roll_count: u8 = 0;
            for (ADJ_OFFSETS) |offset| {
                if (grid.getSafe(x + offset[0], y + offset[1])) |val| {
                    if (val == '@') {
                        adj_roll_count += 1;
                    }
                }
            }

            if (adj_roll_count < 4) {
                grid.set(x, y, '.');
                rolls_removed += 1;
            }
        }

        if (rolls_removed == 0) {
            break;
        }

        result += rolls_removed;
    }

    return result;
}
