const std = @import("std");

const Self = @This();

const Window = @import("../../window.zig");

allocator: std.mem.Allocator,

pub fn createWindow(allocator: std.mem.Allocator) !Window.Context {
    //Allocate a new copy of ourselves
    const self = try allocator.create(Self);
    //Initialize the copy
    self.* = .{
        .allocator = allocator,
    };

    //Return the new created window context
    return .{ .wayland = self };
}

pub fn deinit(self: *Self) void {
    //Free ourselves
    self.allocator.destroy(self);
}
