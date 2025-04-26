const std = @import("std");

const add = @import("./add-decimal.zig").add;
const memcopy = @import("./copy-util.zig").copy;
const LineReader = @import("./line-reader.zig").LineReader(1024 * 1024, 1024 * 1024);

var num_buffer: [1024]u8 = undefined;
var num_buffer_len: usize = undefined;
var num_buffer_tmp: [1024]u8 = undefined;
var input_lines: LineReader = undefined;

pub fn main() !void {
    input_lines.initWithFile(std.io.getStdIn());
    // defer input_lines.deinit();

    num_buffer[0] = '0';
    num_buffer_len = 1;

    var size: u64 = 0;

    while (try input_lines.next()) |line| {
        const split1: usize = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        const split2: usize = split1 + 2;
        const num = line[(split2 + 1)..];

        size += 1;

        const result = add(
            num_buffer_tmp[0..],
            num_buffer[0..num_buffer_len],
            num,
        );

        memcopy(num_buffer[0..], result);
        num_buffer_len = result.len;
    }

    var std_out = std.io.getStdOut();
    try std_out.writer().print("size {} ({s})", .{ size, num_buffer[0..num_buffer_len] });
}
