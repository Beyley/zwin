const std = @import("std");

const Self = @This();

const Window = @import("../../window.zig");

const c = @cImport({
    @cInclude("wayland-client.h");
});

allocator: std.mem.Allocator,
display: *c.struct_wl_display,
compositor: ?*c.struct_wl_compositor,

fn registryHandler(data: ?*anyopaque, registry: ?*c.struct_wl_registry, id: u32, interface_ptr: [*c]const u8, version: u32) callconv(.C) void {
    _ = version; // autofix
    const self: *Self = @ptrCast(@alignCast(data.?));

    const interface = std.mem.sliceTo(interface_ptr, 0);

    if (std.mem.eql(u8, interface, "wl_compositor")) {
        self.compositor = @ptrCast(c.wl_registry_bind(registry, id, &c.wl_compositor_interface, 1));
    }

    std.log.debug("got registry event for {s}, id: {d}", .{ interface, id });
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

    //Initialize the copy
    self.* = .{
        .allocator = allocator,
        .display = display,
        .compositor = null,
    };

    //TODO: handle this return value
    _ = c.wl_registry_add_listener(registry, &.{
        .global = registryHandler,
        .global_remove = registryRemover,
    }, self);

    //TODO: handle this return value
    _ = c.wl_display_dispatch(display);
    //TODO: handle this return value
    _ = c.wl_display_roundtrip(display);

    if (self.compositor == null) return error.UnableToFindWlCompositor;
    std.log.debug("found compositor {*}", .{self.compositor.?});

    const surface = c.wl_compositor_create_surface(self.compositor) orelse return error.FailedToCreateSurface;
    std.log.debug("created surface {*}", .{surface});

    //Return the new created window context
    return .{ .wayland = self };
}

pub fn deinit(self: *Self) void {
    c.wl_display_disconnect(self.display);

    //Free ourselves
    self.allocator.destroy(self);
}
