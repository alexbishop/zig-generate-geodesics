const std = @import("std");

const FabGup = @import("./fabrikowski-gupta.zig");
const LineReader = @import("./line-reader.zig").LineReader(1024 * 1024, 1024 * 1024);

var group_buffer: [1024 * 1024]u8 = undefined;
var input_lines: LineReader = undefined;

pub fn main() !void {
    input_lines.initWithFile(std.io.getStdIn());
    // defer input_lines.deinit();

    var std_out = std.io.getStdOut();

    var output_buffer = std.io.bufferedWriter(std_out.writer());
    var output = output_buffer.writer();

    while (try input_lines.next()) |line| {
        const split1: usize = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        // split1 + 1 is then the descend set
        const desc: FabGup.DescendSet = @bitCast(line[split1 + 1]);
        // split1 + 2 is also a ':'
        const split2: usize = split1 + 2;

        if (desc.a == false and desc.A == false) {
            try output.writeAll(try FabGup.multiply(group_buffer[0..], "a", line[0..split1]));
            try output.writeAll(":");
            try output.writeByte(@bitCast(FabGup.DescendSet{ .a = true }));
            try output.writeAll(line[split2..]);
            try output.writeAll("\n");

            try output.writeAll(try FabGup.multiply(group_buffer[0..], "A", line[0..split1]));
            try output.writeAll(":");
            try output.writeByte(@bitCast(FabGup.DescendSet{ .A = true }));
            try output.writeAll(line[split2..]);
            try output.writeAll("\n");
        }

        if (desc.b == false and desc.B == false) {
            try output.writeAll(try FabGup.multiply(group_buffer[0..], "b", line[0..split1]));
            try output.writeAll(":");
            try output.writeByte(@bitCast(FabGup.DescendSet{ .b = true }));
            try output.writeAll(line[split2..]);
            try output.writeAll("\n");

            try output.writeAll(try FabGup.multiply(group_buffer[0..], "B", line[0..split1]));
            try output.writeAll(":");
            try output.writeByte(@bitCast(FabGup.DescendSet{ .B = true }));
            try output.writeAll(line[split2..]);
            try output.writeAll("\n");
        }
    }

    try output_buffer.flush();
}
