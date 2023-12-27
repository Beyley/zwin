const std = @import("std");
const builtin = @import("builtin");

const Window = @import("window.zig").Window;

const backends = switch (builtin.os.tag) {
    .linux => .{
        @import("backends/wayland/impl.zig"),
    },
    else => @compileError("This platform is not supported yet"),
};

pub fn createWindow(allocator: std.mem.Allocator) !Window {
    const backends_fields = @typeInfo(@TypeOf(backends)).Struct.fields;

    inline for (backends_fields) |backend_field| {
        const Backend = @field(backends, backend_field.name);

        return try Backend.createWindow(allocator);
    }

    return error.Failed;
}
