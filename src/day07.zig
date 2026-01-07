const std = @import("std");

const util = @import("util.zig");

const data = @embedFile("data/day07.txt");

pub fn part1() usize {
    var buf: [64 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    var grid = util.Grid(u8).initFromData(allocator, data) catch unreachable;
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

    return split_count;
}

fn countTimelines(grid: *util.Grid(u8), timeline_counts: *util.Grid(usize), x: i32, y: i32) usize {
    // timeline ends once the beam goes out of bounds
    if (!grid.checkBounds(x, y)) {
        return 1;
    }

    // we already calculated the number of timelines from this cell, return the cached value
    // a timeline count of 0 means we haven't calculated it yet
    if (timeline_counts.get(x, y) != 0) {
        return timeline_counts.get(x, y);
    }

    switch (grid.get(x, y)) {
        '.', 'S' => {
            // beam travels downward
            const count = countTimelines(grid, timeline_counts, x, y + 1);
            timeline_counts.set(x, y, count);
            return count;
        },
        '^' => {
            // beam travels left in one timeline, right in another
            const count = countTimelines(grid, timeline_counts, x - 1, y) + countTimelines(grid, timeline_counts, x + 1, y);
            timeline_counts.set(x, y, count);
            return count;
        },
        else => unreachable,
    }
}

pub fn part2() usize {
    var buf: [256 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    var grid = util.Grid(u8).initFromData(allocator, data) catch unreachable;
    defer grid.deinit();

    var timeline_counts = util.Grid(usize).initFill(allocator, grid.width, grid.height, 0) catch unreachable;
    defer timeline_counts.deinit();

    const start = blk: {
        var coord_it = grid.coords();
        while (coord_it.next()) |coord| {
            if (grid.get(coord[0], coord[1]) == 'S') {
                break :blk coord;
            }
        }
        unreachable; // start should exist
    };

    const result = countTimelines(&grid, &timeline_counts, start[0], start[1]);

    return result;
}
