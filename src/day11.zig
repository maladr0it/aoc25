// https://adventofcode.com/2025/day/11

const std = @import("std");

// const data = @embedFile("data/x.txt");
const data = @embedFile("data/day11.txt");

const MAX_NODES = 1024;
const START_NODE_NAME = "you";
const END_NODE_NAME = "out";

pub fn part1() u64 {
    const AdjMap = std.StringHashMap(std.ArrayListUnmanaged([]const u8));

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

    const buf = std.heap.page_allocator.alloc(u8, 1024 * 1024) catch unreachable;
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
    _ = data; // placeholder until day 11 solution is implemented
    return 0;
}
