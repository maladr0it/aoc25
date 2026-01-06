const std = @import("std");

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
        const self = I32Iterator2D{ .value = .{ 0, 0 }, .to = to };
        return self;
    }

    pub fn next(self: *I32Iterator2D) ?[2]i32 {
        const value = self.value;

        if (value[1] >= self.to[1]) {
            return null;
        }

        self.value[0] += 1;
        if (self.value[0] >= self.to[0]) {
            self.value[0] = 0;
            self.value[1] += 1;
        }

        return value;
    }
};

pub const Grid = struct {
    // all i32 must be valid so we use i32 for dimensions
    height: u31,
    width: u31,
    allocator: std.mem.Allocator,
    data: []u8,

    pub fn initFill(allocator: std.mem.Allocator, width: usize, height: usize, value: u8) !Grid {
        const self = Grid{
            .height = @intCast(height),
            .width = @intCast(width),
            .allocator = allocator,
            .data = try allocator.alloc(u8, width * height),
        };

        @memset(self.data, value);

        return self;
    }

    pub fn initFromData(allocator: std.mem.Allocator, data_in: []const u8) !Grid {
        // first pass: determine dimensions
        var width: usize = 0;
        var height: usize = 0;
        var lines = std.mem.tokenizeScalar(u8, data_in, '\n');
        while (lines.next()) |line| {
            width = line.len;
            height += 1;
        }

        var self = Grid{
            .height = @intCast(height),
            .width = @intCast(width),
            .allocator = allocator,
            .data = try allocator.alloc(u8, width * height),
        };

        @memset(self.data, 0);

        // second pass: copy each row into flat storage
        var lines2 = std.mem.tokenizeScalar(u8, data_in, '\n');
        var row: usize = 0;
        while (lines2.next()) |line| {
            const start = row * width;
            std.mem.copyForwards(u8, self.data[start .. start + line.len], line);
            row += 1;
        }

        return self;
    }

    pub fn deinit(self: *Grid) void {
        self.allocator.free(self.data);
    }

    pub fn checkBounds(self: *Grid, x: i32, y: i32) bool {
        return (x >= 0 and x < self.width and y >= 0 and y < self.height);
    }

    pub fn get(self: *Grid, x: i32, y: i32) u8 {
        const idx = self.getIndex(x, y);
        return self.data[idx];
    }

    pub fn set(self: *Grid, x: i32, y: i32, value: u8) void {
        const idx = self.getIndex(x, y);
        self.data[idx] = value;
    }

    // gets while checking bounds
    pub fn getSafe(self: *Grid, x: i32, y: i32) ?u8 {
        if (self.checkBounds(x, y)) {
            return self.get(x, y);
        }
        return null;
    }

    pub fn getIndex(self: *Grid, x: i32, y: i32) usize {
        if (!self.checkBounds(x, y)) {
            std.debug.print("\nOOB {d},{d}\n", .{ x, y });
        }

        const index = @as(usize, @intCast(y)) * @as(usize, @intCast(self.width)) + @as(usize, @intCast(x));
        return index;
    }

    // sets while checking bounds
    pub fn setSafe(self: *Grid, x: i32, y: i32, value: u8) bool {
        if (self.checkBounds(x, y)) {
            self.set(x, y, value);
            return true;
        }
        return false;
    }

    pub fn coords(self: *Grid) I32Iterator2D {
        return I32Iterator2D{ .value = .{ 0, 0 }, .to = .{ self.width, self.height } };
    }

    pub fn rowCoords(self: *Grid) I32Iterator {
        return I32Iterator{ .value = 0, .to = self.height };
    }

    pub fn colCoords(self: *Grid) I32Iterator {
        return I32Iterator{ .value = 0, .to = self.width };
    }

    pub fn print(self: *Grid) void {
        for (0..self.height) |row| {
            const start = row * @as(usize, @intCast(self.width));
            const end = start + @as(usize, @intCast(self.width));
            std.debug.print("{s}\n", .{self.data[start..end]});
        }
    }
};
