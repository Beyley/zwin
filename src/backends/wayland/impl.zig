const std = @import("std");

const Self = @This();

const Window = @import("../../window.zig");

const c = @cImport({
    @cInclude("wayland-client.h");
});

allocator: std.mem.Allocator,
display: *c.struct_wl_display,

fn registryHandler(data: ?*anyopaque, registry: ?*c.struct_wl_registry, id: u32, interface: [*c]const u8, version: u32) callconv(.C) void {
    _ = data; // autofix
    _ = registry; // autofix
    _ = version; // autofix
    std.log.debug("got registry event for {s}, id: {d}", .{ std.mem.sliceTo(interface, 0), id });
}
fn registryRemover(data: ?*anyopaque, registry: ?*c.struct_wl_registry, id: u32) callconv(.C) void {
    _ = data; // autofix
    _ = registry; // autofix
    std.log.debug("got registry removal event for id {d}", .{id});
}

pub fn createWindow(allocator: std.mem.Allocator) !Window.Context {
    //Allocate a new copy of ourselves
    const self = try allocator.create(Self);
    //If theres an error, destroy the pointer
    errdefer allocator.destroy(self);

    const display = c.wl_display_connect(null) orelse return error.CouldntOpenWaylandDisplay;
    std.log.debug("opened wayland display {*}", .{display});

    const registry = c.wl_display_get_registry(display) orelse return error.CouldntGetDisplayRegistry;
    std.log.debug("got display registry {*}", .{registry});

    //TODO: handle this return value
    _ = c.wl_registry_add_listener(registry, &.{
        .global = registryHandler,
        .global_remove = registryRemover,
    }, null);

    //TODO: handle this return value
    _ = c.wl_display_dispatch(display);
    //TODO: handle this return value
    _ = c.wl_display_roundtrip(display);

    //Initialize the copy
    self.* = .{
        .allocator = allocator,
        .display = display,
        // .display = undefined,
    };

    //Return the new created window context
    return .{ .wayland = self };
}

pub fn deinit(self: *Self) void {
    c.wl_display_disconnect(self.display);

    //Free ourselves
    self.allocator.destroy(self);
}
