// https://adventofcode.com/2025/day/9

const std = @import("std");

const util = @import("util.zig");

const data = @embedFile("data/x.txt");
// const data = @embedFile("data/day09.txt");

const MAX_POINTS = 512;

pub fn part1() u64 {
    var buf: [MAX_POINTS][2]i64 = undefined;
    var points = std.ArrayList([2]i64).initBuffer(&buf);

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var parts = std.mem.splitScalar(u8, line, ',');
        const x_str = parts.next().?;
        const y_str = parts.next().?;
        const x = std.fmt.parseInt(i64, x_str, 10) catch unreachable;
        const y = std.fmt.parseInt(i64, y_str, 10) catch unreachable;
        points.appendAssumeCapacity(.{ x, y });
    }

    var max_area: u64 = 0;

    for (0..points.items.len) |i| {
        const p1 = points.items[i];
        for (i + 1..points.items.len) |j| {
            const p2 = points.items[j];
            const area = @abs((p1[0] - p2[0] + 1) * (p1[1] - p2[1] + 1));
            max_area = @max(area, max_area);
        }
    }

    return max_area;
}

pub fn part2() usize {
    const allocator = std.heap.page_allocator;

    var points = std.ArrayList([2]i64).initCapacity(allocator, MAX_POINTS) catch unreachable;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var parts = std.mem.splitScalar(u8, line, ',');
        const x_str = parts.next().?;
        const y_str = parts.next().?;
        const x = std.fmt.parseInt(i64, x_str, 10) catch unreachable;
        const y = std.fmt.parseInt(i64, y_str, 10) catch unreachable;
        points.appendAssumeCapacity(.{ x, y });
    }

    // assert
    if (points.items.len == 0) {
        unreachable;
    }

    const sorted_points = points.clone(allocator) catch unreachable;

    // compress x coords
    std.mem.sort([2]i64, sorted_points.items, {}, struct {
        fn lessThan(context: void, a: [2]i64, b: [2]i64) bool {
            _ = context;
            return a[0] < b[0];
        }
    }.lessThan);

    var x_map = std.AutoHashMap(i64, i32).init(allocator);
    x_map.ensureTotalCapacity(MAX_POINTS) catch unreachable;
    var compressed_x: i32 = 1; // start at 1 so we have padding around the shape
    x_map.put(sorted_points.items[0][0], compressed_x) catch unreachable;

    for (1..sorted_points.items.len) |i| {
        const prev_x = sorted_points.items[i - 1][0];
        const cur_x = sorted_points.items[i][0];
        if (cur_x == prev_x + 1) {
            compressed_x += 1;
            x_map.put(cur_x, compressed_x) catch unreachable;
        } else if (cur_x > prev_x + 1) {
            // create a gap so the tiles aren't adjacent
            compressed_x += 2;
            x_map.put(cur_x, compressed_x) catch unreachable;
        }
    }

    // compress y coords
    std.mem.sort([2]i64, sorted_points.items, {}, struct {
        fn lessThan(context: void, a: [2]i64, b: [2]i64) bool {
            _ = context;
            return a[1] < b[1];
        }
    }.lessThan);

    var y_map = std.AutoHashMap(i64, i32).init(allocator);
    y_map.ensureTotalCapacity(MAX_POINTS) catch unreachable;
    var compressed_y: i32 = 1; // start at 1 so we have padding around the shape
    y_map.put(sorted_points.items[0][1], compressed_y) catch unreachable;

    for (1..sorted_points.items.len) |i| {
        const prev_y = sorted_points.items[i - 1][1];
        const cur_y = sorted_points.items[i][1];
        if (cur_y == prev_y + 1) {
            compressed_y += 1;
            y_map.put(cur_y, compressed_y) catch unreachable;
        } else if (cur_y > prev_y + 1) {
            // create a gap so the tiles aren't adjacent
            compressed_y += 2;
            y_map.put(cur_y, compressed_y) catch unreachable;
        }
    }

    // create compressed grid
    var grid = util.Grid(u8).initFill(
        allocator,
        // add an extra 1 size to the dimensions so we have padding around the shape
        @intCast(compressed_x + 2),
        @intCast(compressed_y + 2),
        '.',
    ) catch unreachable;
    defer grid.deinit();

    // draw the map
    for (0..points.items.len) |i| {
        const p1 = points.items[i];
        const p2 = points.items[(i + 1) % points.items.len];
        const x1 = x_map.get(p1[0]) orelse unreachable;
        const y1 = y_map.get(p1[1]) orelse unreachable;
        const x2 = x_map.get(p2[0]) orelse unreachable;
        const y2 = y_map.get(p2[1]) orelse unreachable;
        const dx = std.math.sign(x2 - x1);
        const dy = std.math.sign(y2 - y1);

        grid.set(x1, y1, '#');
        var x = x1 + dx;
        var y = y1 + dy;
        while (x != x2 or y != y2) {
            grid.set(x, y, 'X');
            x += dx;
            y += dy;
        }
    }

    grid.print();

    grid.floodFill(0, 0, '.', '!') catch unreachable;

    grid.print();

    // later: use a heap and just store the ~100 biggest

    for (0..points.items.len) |i| {
        const p1 = points.items[i];
        _ = p1; // autofix
        for (i..points.items.len) |j| {
            const p2 = points.items[j];
            _ = p2; // autofix

        }
    }

    var pairs = std.ArrayList(); // HERE
    _ = pairs; // autofix

    // okay now check every rectangle, from the largest and see if we have a fit

    // for (points.items) |point| {
    //     grid.set(x_map.get(point[0]), y_map.get(point[1]), '#');
    // }

    return 0;
}
