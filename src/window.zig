const std = @import("std");

const wayland_enabled = true;

const UnreachableBackend = struct {
    pub fn deinit(self: UnreachableBackend) void {
        _ = self; // autofix

        unreachable;
    }
};

pub const Window = union(enum) {
    wayland: if (wayland_enabled) @import("backends/wayland/impl.zig") else UnreachableBackend,

    const TypeInfo = @typeInfo(Window);

    pub fn deinit(self: Window) void {
        switch (self) {
            inline else => |window| window.deinit(),
        }
    }
};
