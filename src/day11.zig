// https://adventofcode.com/2025/day/11

const std = @import("std");

const data = @embedFile("data/day11.txt");

const MAX_NODES = 1024;

const AdjMap = std.StringHashMap(std.ArrayListUnmanaged([]const u8));

pub fn part1() u64 {
    const START_NODE_NAME = "you";
    const END_NODE_NAME = "out";

    const Ctx = struct {
        adj_map: *AdjMap,
        memo: *std.StringHashMap(u64),

        const Self = @This();

        fn dfs(self: *Self, node: []const u8) u64 {
            // reached target node, 1 path found
            if (std.mem.eql(u8, node, END_NODE_NAME)) {
                return 1;
            }

            // node has no outward connections, end of path
            const out_nodes = self.adj_map.get(node) orelse {
                return 0;
            };

            const memo_entry = self.memo.getOrPutAssumeCapacity(node);
            if (memo_entry.found_existing) {
                return memo_entry.value_ptr.*;
            }

            var path_count: u64 = 0;
            for (out_nodes.items) |out_node| {
                const count = self.dfs(out_node);
                path_count += count;
            }
            memo_entry.value_ptr.* = path_count;

            return path_count;
        }
    };

    const buf = std.heap.page_allocator.alloc(u8, 256 * 1024) catch unreachable;
    defer std.heap.page_allocator.free(buf);
    var fba = std.heap.FixedBufferAllocator.init(buf);
    const allocator = fba.allocator();

    var adj_map = AdjMap.init(allocator);
    defer adj_map.deinit();
    adj_map.ensureTotalCapacity(MAX_NODES) catch unreachable;

    var line_it = std.mem.splitScalar(u8, data, '\n');
    while (line_it.next()) |line| {
        const colon_pos = std.mem.indexOfScalar(u8, line, ':').?;
        const name = line[0..colon_pos];

        var entry = adj_map.getOrPutAssumeCapacity(name);
        // assume no duplicate entries therefore nothing to overwrite
        if (entry.found_existing) {
            unreachable;
        }
        entry.value_ptr.* = .{};
        // +2 to skip colon and the space after it
        var out_str_it = std.mem.splitScalar(u8, line[colon_pos + 2 ..], ' ');
        while (out_str_it.next()) |out_str| {
            entry.value_ptr.append(allocator, out_str) catch unreachable;
        }
    }

    var memo = std.StringHashMap(u64).init(allocator);
    defer memo.deinit();
    memo.ensureTotalCapacity(MAX_NODES) catch unreachable;

    var ctx = Ctx{ .adj_map = &adj_map, .memo = &memo };
    const result = ctx.dfs(START_NODE_NAME);

    return result;
}

pub fn part2() u64 {
    const START_NODE_NAME = "svr";
    const END_NODE_NAME = "out";
    const DAC_NODE_NAME = "dac";
    const FFT_NODE_NAME = "fft";

    const SEEN_DAC = 1 << 0;
    const SEEN_FFT = 1 << 1;

    // 4 possible visit states, based on whether dac and fft have been visited
    const Memo = std.StringHashMap([4]?u64);

    const buf = std.heap.page_allocator.alloc(u8, 1024 * 1024) catch unreachable;
    defer std.heap.page_allocator.free(buf);
    var fba = std.heap.FixedBufferAllocator.init(buf);
    const allocator = fba.allocator();

    const Ctx = struct {
        adj_map: *AdjMap,
        memo: *Memo,

        const Self = @This();

        fn dfs(self: *Self, node: []const u8, visit_state: u2) u64 {
            // reached target node
            if (std.mem.eql(u8, node, END_NODE_NAME)) {
                // have visited both dac and fft, 1 path found
                if (visit_state == (SEEN_DAC | SEEN_FFT)) {
                    return 1;
                }
                return 0;
            }

            // node has no outward connections, end of path
            const out_nodes = self.adj_map.get(node) orelse {
                return 0;
            };

            const memo_entry = self.memo.getOrPutAssumeCapacity(node);
            if (memo_entry.found_existing) {
                if (memo_entry.value_ptr[visit_state]) |cached| {
                    return cached;
                }
            } else {
                memo_entry.value_ptr.* = .{null} ** 4;
            }

            var next_visit_state = visit_state;
            if (std.mem.eql(u8, node, DAC_NODE_NAME)) {
                next_visit_state |= SEEN_DAC;
            }
            if (std.mem.eql(u8, node, FFT_NODE_NAME)) {
                next_visit_state |= SEEN_FFT;
            }

            var path_count: u64 = 0;
            for (out_nodes.items) |out_node| {
                const count = self.dfs(out_node, next_visit_state);
                path_count += count;
            }
            memo_entry.value_ptr[visit_state] = path_count;

            return path_count;
        }
    };

    var adj_map = AdjMap.init(allocator);
    defer adj_map.deinit();
    adj_map.ensureTotalCapacity(MAX_NODES) catch unreachable;

    var line_it = std.mem.splitScalar(u8, data, '\n');
    while (line_it.next()) |line| {
        const colon_pos = std.mem.indexOfScalar(u8, line, ':').?;
        const name = line[0..colon_pos];

        var entry = adj_map.getOrPutAssumeCapacity(name);
        // assume no duplicate entries therefore nothing to overwrite
        if (entry.found_existing) {
            unreachable;
        }
        entry.value_ptr.* = .{};
        // +2 to skip colon and the space after it
        var out_str_it = std.mem.splitScalar(u8, line[colon_pos + 2 ..], ' ');
        while (out_str_it.next()) |out_str| {
            entry.value_ptr.append(allocator, out_str) catch unreachable;
        }
    }

    var memo = Memo.init(allocator);
    defer memo.deinit();
    memo.ensureTotalCapacity(MAX_NODES) catch unreachable;

    var ctx = Ctx{ .adj_map = &adj_map, .memo = &memo };
    const result = ctx.dfs(START_NODE_NAME, 0);

    return result;
}
