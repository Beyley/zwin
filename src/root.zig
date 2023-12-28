const std = @import("std");
const builtin = @import("builtin");

const Window = @import("window.zig");

pub fn createWindow(allocator: std.mem.Allocator) !Window.Window {
    const backends_fields = @typeInfo(Window.Context).Union.fields;

    inline for (backends_fields) |backend_field| {
        //Try to run the create function on the backend (unwrapping the backend field, which is a pointer)
        return .{ .context = try @typeInfo(backend_field.type).Pointer.child.createWindow(allocator) };
    }

    return error.Failed;
}
