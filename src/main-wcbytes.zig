//! A faster alternative to `wc --bytes`
const std = @import("std");

var buffer: [1024 * 1024]u8 = undefined;

pub fn main() !void {
    const file = std.io.getStdIn();
    var total: u64 = 0;
    while (true) {
        const read_len = try file.read(buffer[0..]);
        if (read_len == 0) {
            try std.io.getStdOut().writer().print("{}\n", .{total});
            return;
        } else {
            total += read_len;
        }
    }
}
