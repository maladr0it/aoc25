// https://adventofcode.com/2025/day/8

const std = @import("std");

const util = @import("util.zig");

const data = @embedFile("data/day08.txt");

const MAX_BOX_COUNT = 1000;
const MAX_PAIR_COUNT = (MAX_BOX_COUNT * (MAX_BOX_COUNT - 1)) / 2;

const UnionFind = struct {
    parent: []u16, // parent[i] = j means i is a child of j
    component_count: usize,

    fn init(allocator: std.mem.Allocator, n: usize) !UnionFind {
        var parent = try allocator.alloc(u16, n);
        for (0..n) |i| {
            parent[i] = @intCast(i); // each element is its own parent
        }
        return .{ .parent = parent, .component_count = n };
    }

    fn deinit(self: *UnionFind, allocator: std.mem.Allocator) void {
        allocator.free(self.parent);
    }

    fn find(self: *UnionFind, a: u16) u16 {
        if (self.parent[a] != a) {
            self.parent[a] = self.find(self.parent[a]); // path compression
        }
        return self.parent[a];
    }

    fn merge(self: *UnionFind, a: u16, b: u16) bool {
        const root_a = self.find(a);
        const root_b = self.find(b);

        if (root_a == root_b) {
            // already same circuit, no new union made
            return false;
        }

        self.parent[root_a] = root_b; // merge
        self.component_count -= 1;
        return true; // successfully joined two unions
    }
};

const Pair = struct {
    // avoid sqrt for performance
    // use a f32 to represent higher numbers than i32
    // precision at the high end doesn't matter since we only work with the the 1000 smallest distances
    dist_sq: f32,
    i: u16,
    j: u16,
};

pub fn part1() usize {
    const CONNECTIONS_COUNT = 1000;

    var buf: [256 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    const positions = allocator.create([MAX_BOX_COUNT][3]f32) catch unreachable;

    var box_count: u16 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var parts = std.mem.splitScalar(u8, line, ',');
        const x_str = parts.next().?;
        const y_str = parts.next().?;
        const z_str = parts.next().?;
        const x = std.fmt.parseFloat(f32, x_str) catch unreachable;
        const y = std.fmt.parseFloat(f32, y_str) catch unreachable;
        const z = std.fmt.parseFloat(f32, z_str) catch unreachable;

        positions[box_count] = .{ x, y, z };
        box_count += 1;
    }

    // store the n smallest pairs in a heap, prioritized by LARGEST distance
    var heap = std.PriorityQueue(Pair, void, struct {
        fn compare(context: void, a: Pair, b: Pair) std.math.Order {
            _ = context;
            return std.math.order(b.dist_sq, a.dist_sq); // largest are prioritized
        }
    }.compare).init(allocator, {});
    heap.ensureTotalCapacity(CONNECTIONS_COUNT) catch unreachable;

    // find the CONNECTIONS_COUNT closest pairs
    for (0..box_count) |i| {
        const i_id: u16 = @intCast(i);
        for (i + 1..box_count) |j| {
            const j_id: u16 = @intCast(j);

            const pos_i = positions[i_id];
            const pos_j = positions[j_id];
            const dx = pos_i[0] - pos_j[0];
            const dy = pos_i[1] - pos_j[1];
            const dz = pos_i[2] - pos_j[2];
            const dist_sq = dx * dx + dy * dy + dz * dz;
            const pair = Pair{ .dist_sq = dist_sq, .i = i_id, .j = j_id };

            if (heap.count() < CONNECTIONS_COUNT) {
                heap.add(pair) catch unreachable;
            } else {
                const largest = heap.peek().?;
                if (pair.dist_sq < largest.dist_sq) {
                    _ = heap.remove();
                    heap.add(pair) catch unreachable;
                }
            }
        }
    }

    // connect all pairs into unions
    var union_find = UnionFind.init(allocator, box_count) catch unreachable;
    for (heap.items) |pair| {
        _ = union_find.merge(pair.i, pair.j);
    }

    // get the three largest union sizes
    var union_sizes = [_]usize{0} ** MAX_BOX_COUNT;

    for (0..box_count) |i| {
        const box_id: u16 = @intCast(i);
        const root: u16 = union_find.find(box_id);
        union_sizes[root] += 1;
    }
    // just sort the whole array since it's ~1000 long
    std.mem.sort(usize, union_sizes[0..box_count], {}, std.sort.desc(usize));

    var result: usize = 0;
    for (0..3) |i| {
        result = @max(result, 1) * union_sizes[i];
    }

    return result;
}

pub fn part2() f64 {
    const HEAP_BUF_SIZE = 4 * 1024 * 1024;
    const heap_buf = std.heap.page_allocator.alloc(u8, HEAP_BUF_SIZE) catch unreachable;
    defer std.heap.page_allocator.free(heap_buf);

    var fba = std.heap.FixedBufferAllocator.init(heap_buf);
    const allocator = fba.allocator();

    const positions = allocator.create([MAX_BOX_COUNT][3]f32) catch unreachable;

    var box_count: u16 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var parts = std.mem.splitScalar(u8, line, ',');
        const x_str = parts.next().?;
        const y_str = parts.next().?;
        const z_str = parts.next().?;
        const x = std.fmt.parseFloat(f32, x_str) catch unreachable;
        const y = std.fmt.parseFloat(f32, y_str) catch unreachable;
        const z = std.fmt.parseFloat(f32, z_str) catch unreachable;

        positions[box_count] = .{ x, y, z };
        box_count += 1;
    }

    var pairs = std.ArrayList(Pair).initCapacity(allocator, MAX_PAIR_COUNT) catch unreachable;

    // sort all pairs by distance
    for (0..box_count) |i| {
        const i_id: u16 = @intCast(i);
        for (i + 1..box_count) |j| {
            const j_id: u16 = @intCast(j);

            const pos_i = positions[i_id];
            const pos_j = positions[j_id];
            const dx = pos_i[0] - pos_j[0];
            const dy = pos_i[1] - pos_j[1];
            const dz = pos_i[2] - pos_j[2];
            const dist_sq = dx * dx + dy * dy + dz * dz;
            const pair = Pair{ .dist_sq = dist_sq, .i = i_id, .j = j_id };

            pairs.appendAssumeCapacity(pair);
        }
    }

    std.mem.sort(Pair, pairs.items, {}, struct {
        fn lessThan(_: void, a: Pair, b: Pair) bool {
            return a.dist_sq < b.dist_sq;
        }
    }.lessThan);

    // connect pairs until they make one union
    var result: f64 = 0; // f64 since f32 will lose precision
    var union_find = UnionFind.init(allocator, box_count) catch unreachable;
    for (pairs.items) |pair| {
        _ = union_find.merge(pair.i, pair.j);
        if (union_find.component_count == 1) {
            const pos_i = positions[pair.i];
            const pos_j = positions[pair.j];
            result = @as(f64, pos_i[0]) * @as(f64, pos_j[0]);
            break;
        }
    }

    return result;
}
