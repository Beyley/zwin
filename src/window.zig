const std = @import("std");
const builtin = @import("builtin");

pub const Context = switch (builtin.os.tag) {
    .linux => union(enum) {
        wayland: *@import("backends/wayland/impl.zig"),
    },
    else => @compileError("Unknown OS"),
};

pub const Window = union(enum) {
    context: Context,

    const TypeInfo = @typeInfo(Window);

    ///Destroys all held memory and resources
    pub fn deinit(self: Window) void {
        switch (self.context) {
            inline else => |window| window.deinit(),
        }
    }
};
