const std = @import("std");

const util = @import("util.zig");

const data = @embedFile("data/day07.txt");

pub fn part1() usize {
    var buf: [64 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    var grid = util.Grid.initFromData(allocator, data) catch unreachable;
    defer grid.deinit();

    const start = blk: {
        var coord_it = grid.coords();
        while (coord_it.next()) |coord| {
            if (grid.get(coord[0], coord[1]) == 'S') {
                break :blk coord;
            }
        }
        unreachable; // start should exist
    };

    grid.set(start[0], start[1], '|');
    var split_count: usize = 0;

    var row: i32 = 1; // skip the first row
    while (row < grid.height) : (row += 1) {
        var col: i32 = 0;
        while (col < grid.width) : (col += 1) {
            if (grid.get(col, row - 1) == '|') {
                switch (grid.get(col, row)) {
                    // the beam travels downward freely
                    '.' => {
                        grid.set(col, row, '|');
                    },
                    // the beam splits
                    '^' => {
                        split_count += 1;
                        if (grid.getSafe(col - 1, row) == '.') {
                            grid.set(col - 1, row, '|');
                        }
                        if (grid.getSafe(col + 1, row) == '.') {
                            grid.set(col + 1, row, '|');
                        }
                    },
                    else => {},
                }
            }
        }
    }
    // grid.print();

    return split_count;
}

pub fn part2() usize {
    return 0;
}
