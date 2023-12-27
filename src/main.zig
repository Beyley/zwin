const std = @import("std");
const zwin = @import("zwin");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if(gpa.deinit() == .leak) @panic("MEMORY LEAK");
    const allocator = gpa.allocator();
    
    const window = try zwin.createWindow(allocator);
    defer window.deinit();
}
