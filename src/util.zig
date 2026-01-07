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

pub fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();

        height: u31,
        width: u31,
        allocator: std.mem.Allocator,
        data: []T,

        pub fn initFill(allocator: std.mem.Allocator, width: usize, height: usize, value: T) !Self {
            const self = Self{
                .height = @intCast(height),
                .width = @intCast(width),
                .allocator = allocator,
                .data = try allocator.alloc(T, width * height),
            };
            @memset(self.data, value);
            return self;
        }

        pub fn initFromData(allocator: std.mem.Allocator, data_in: []const u8) !Self {
            comptime if (T != u8) @compileError("initFromData only works with Grid(u8)");

            var width: usize = 0;
            var height: usize = 0;
            var lines = std.mem.tokenizeScalar(u8, data_in, '\n');
            while (lines.next()) |line| {
                width = line.len;
                height += 1;
            }

            var self = Self{
                .height = @intCast(height),
                .width = @intCast(width),
                .allocator = allocator,
                .data = try allocator.alloc(T, width * height),
            };

            lines.reset();
            var row: usize = 0;
            while (lines.next()) |line| {
                const start = row * width;
                std.mem.copyForwards(u8, self.data[start .. start + line.len], line);
                row += 1;
            }

            return self;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.data);
        }

        pub fn checkBounds(self: *Self, x: i32, y: i32) bool {
            return (x >= 0 and x < self.width and y >= 0 and y < self.height);
        }

        pub fn get(self: *Self, x: i32, y: i32) T {
            return self.data[self.getIndex(x, y)];
        }

        pub fn set(self: *Self, x: i32, y: i32, value: T) void {
            self.data[self.getIndex(x, y)] = value;
        }

        pub fn getSafe(self: *Self, x: i32, y: i32) ?T {
            if (self.checkBounds(x, y)) return self.get(x, y);
            return null;
        }

        pub fn getIndex(self: *Self, x: i32, y: i32) usize {
            return @as(usize, @intCast(y)) * @as(usize, self.width) + @as(usize, @intCast(x));
        }

        pub fn setSafe(self: *Self, x: i32, y: i32, value: T) bool {
            if (self.checkBounds(x, y)) {
                self.set(x, y, value);
                return true;
            }
            return false;
        }

        pub fn coords(self: *Self) I32Iterator2D {
            return I32Iterator2D{ .value = .{ 0, 0 }, .to = .{ self.width, self.height } };
        }

        pub fn rowCoords(self: *Self) I32Iterator {
            return I32Iterator{ .value = 0, .to = self.height };
        }

        pub fn colCoords(self: *Self) I32Iterator {
            return I32Iterator{ .value = 0, .to = self.width };
        }

        pub fn print(self: *Self) void {
            comptime if (T != u8) @compileError("print only works with Grid(u8)");

            for (0..self.height) |row| {
                const start = row * @as(usize, @intCast(self.width));
                const end = start + @as(usize, @intCast(self.width));
                std.debug.print("{s}\n", .{self.data[start..end]});
            }
        }
    };
}
