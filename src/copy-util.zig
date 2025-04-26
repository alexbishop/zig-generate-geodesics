pub fn copy(dest: []u8, source: []const u8) void {
    if (dest.len < source.len) @panic("Cannot copy, not enough room");
    @memcpy(dest[0..source.len], source);
}
