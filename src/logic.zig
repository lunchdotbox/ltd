const std = @import("std");

pub fn isInList(value: anytype, list: anytype) bool {
    for (list) |element| if (element == value) return true;

    return false;
}

test "is element in list function" {
    const list = [_]u32{ 1, 2, 6, 20 };
    try std.testing.expect(isInList(6, list));
    try std.testing.expect(!isInList(12, list));
}
