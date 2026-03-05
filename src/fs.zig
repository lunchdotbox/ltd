const std = @import("std");
const builtin = @import("builtin");

pub fn memoryMapFile(file: std.fs.File) ![]align(std.heap.page_size_min) u8 {
    if (builtin.os.tag == .windows) @compileError("MMap is not supported on windows");

    const md = try file.stat();
    const ptr = try std.posix.mmap(null, md.size, std.posix.PROT.READ | std.posix.PROT.WRITE, .{ .TYPE = .SHARED }, file.handle, 0);

    return ptr[0..md.size];
}

pub fn memoryUnmap(memory: []align(std.heap.page_size_min) const u8) void {
    if (builtin.os.tag == .windows) @compileError("MUnmap is not supported on windows");

    std.posix.munmap(memory);
}

test "file memory mapping" {
    if (builtin.os.tag == .windows) return;

    const file = try std.fs.cwd().createFile("test_file.txt", .{});
    _ = try file.write("test text");
    try file.sync();
    file.close();

    const mapped_file = try std.fs.cwd().openFile("test_file.txt", .{ .mode = .read_write });

    const memory = try memoryMapFile(mapped_file);
    try std.testing.expectEqualStrings(memory, "test text");
    memoryUnmap(memory);

    mapped_file.close();

    try std.fs.cwd().deleteFile("test_file.txt");
}
