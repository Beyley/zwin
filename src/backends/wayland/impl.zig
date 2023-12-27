const std = @import("std");

const Self = @This();

const Window = @import("../../window.zig").Window;

pub fn createWindow(allocator: std.mem.Allocator) !Window {
    _ = allocator; // autofix
    return .{ .wayland = .{} };
}

pub fn deinit(self: Self) void {
    _ = self; // autofix
}
