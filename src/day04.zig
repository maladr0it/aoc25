const std = @import("std");

// const data = @embedFile("data/x.txt");
const data = @embedFile("data/day04.txt");

const MAX_GRID_WIDTH = 256;
const MAX_GRID_HEIGHT = 256;

const I32Iterator = struct {
    value: i32,
    to: i32,

    pub fn init(to: i32) I32Iterator {
        const self = I32Iterator{ .value = 0, .to = to };
        return self;
    }

    pub fn next(self: *I32Iterator) ?i32 {
        const value = self.value;

        if (value >= self.to) {
            return null;
        }

        self.value += 1;
        return value;
    }
};

const I32Iterator2D = struct {
    value: [2]i32,
    to: [2]i32,

    pub fn init(to: [2]i32) I32Iterator2D {
        const self = I32Iterator2D{ .value = .{0,0}, .to = to };
        return self;
    }

    pub fn next(self: *I32Iterator2D) ?[2]i32 {
        const value = self.value;

        if (value[1] > self.to[1]) {
            return null;
        }

        var next_col = value[0] + 1;
        var next_row = value[1];
        if (next_col > self.to[0]) {
            next_col = 0;
            next_row += 1;
        }

        self.value = .{ next_col, next_row };
        return value;
    }
};

const Grid = struct {
    // all i32 must be valid so we use i32 for dimensions
    height: u31,
    width: u31,
    data: [MAX_GRID_HEIGHT][MAX_GRID_WIDTH]u8,

    pub fn initFill(width: usize, height: usize, value: u8) Grid {
        var self = Grid{
            .height = @intCast(height),
            .width = @intCast(width),
            .data = undefined
        };

        for (0..height) |row| {
            @memset(self.data[row][0..], value);
        }

        return self;
    }

    pub fn initFromData(data_in: []const u8) Grid {
        var self = Grid{ .height = 0, .width = 0, .data = undefined };

        var lines = std.mem.tokenizeScalar(u8, data_in, '\n');
        while (lines.next()) |line| {
            for (line, 0..) |c, i| {
                self.data[self.height][i] = c;
            }
            self.width = @intCast(line.len);
            self.height += 1;
        }

        return self;
    }

    pub fn get(self: *Grid, x: i32, y: i32) ?u8 {
        if (x >= 0 and x < self.width and y >= 0 and y < self.width) {
            return self.data[@as(usize, @intCast(y))][@as(usize, @intCast(x))];
        }
        return null;
    }

    pub fn set(self: *Grid, x: i32, y: i32, value: u8) void {
        if (x >= 0 and x < self.width and y >= 0 and y < self.width) {
            self.data[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = value;
        }
    }

    pub fn coords(self: *Grid) I32Iterator2D {
        return I32Iterator2D{
            .value = .{0,0},
            .to = .{@intCast(self.width), @intCast(self.height)}
        };
    }

    pub fn row_coords(self: *Grid) I32Iterator {
        return I32Iterator{
            .value = 0,
            .to = @intCast(self.height)
        };
    }

    pub fn col_coords(self: *Grid) I32Iterator {
        return I32Iterator{
            .value = 0,
            .to = @intCast(self.width)
        };
    }

    pub fn print(self: *Grid) void {
        for (0..self.height) |row| {
            for (0..self.width) |col| {
                std.debug.print("{c}", .{self.data[row][col]});
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn part1() usize {
    const ADJ_OFFSETS =[_][2]i32{
        .{ -1, -1 },
        .{ 0, -1 },
        .{ 1, -1 },
        .{ -1, 0 },
        .{ 1, 0 },
        .{ -1, 1 },
        .{ 0, 1 },
        .{ 1, 1 },
    };

    var grid = Grid.initFromData(data);
    var result: usize = 0;

    var coords = grid.coords();
    while (coords.next()) |coord| {
        const x = coord[0];
        const y = coord[1];

        if (grid.get(x, y) != '@') {
            continue;
        }

        var adj_roll_count: u8 = 0;
        for (ADJ_OFFSETS) |offset| {
            if (grid.get(x + offset[0], y + offset[1])) |val| {
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
    return 0;
}