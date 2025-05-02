const std = @import("std");

const add = @import("./add-decimal.zig").add;
const FabGup = @import("./fabrikowski-gupta.zig");
const memcopy = @import("./copy-util.zig").copy;
const LineReader = @import("./line-reader.zig").LineReader(1024 * 1024, 1024 * 1024);

var group_buffer: [1024 * 1024]u8 = undefined;
var number_buffer: [1024]u8 = undefined;
var number_buffer_tmp: [1024]u8 = undefined;
var input_lines: LineReader = undefined;

pub fn main() !void {
    input_lines.initWithFile(std.io.getStdIn());
    // defer input_lines.deinit();

    var std_out = std.io.getStdOut();

    var output_buffer = std.io.bufferedWriter(std_out.writer());
    var output = output_buffer.writer();

    var has_buffered_entry: bool = false;
    var desc_set: FabGup.DescendSet = .{};
    var num_buffer_len: usize = 0;
    var group_buffer_len: usize = 0;

    while (try input_lines.next()) |line| {
        const split1: usize = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        const local_desc: FabGup.DescendSet = @bitCast(line[split1 + 1]);
        const split2: usize = split1 + 2;

        const grp = line[0..split1];
        const num = line[(split2 + 1)..];

        if (!has_buffered_entry) {
            memcopy(group_buffer[0..], grp);
            group_buffer_len = grp.len;

            memcopy(number_buffer[0..], num);
            num_buffer_len = num.len;

            desc_set = local_desc;

            has_buffered_entry = true;
            continue;
        }

        if (std.mem.eql(u8, grp, group_buffer[0..group_buffer_len])) {
            // this is equivalent to the previously seen element
            // so let's add the total
            const result = add(
                number_buffer_tmp[0..],
                number_buffer[0..num_buffer_len],
                num,
            );
            @memcpy(number_buffer[0..result.len], result);
            num_buffer_len = result.len;

            // take the union of the descend sets
            desc_set = @bitCast(@as(u8, @bitCast(local_desc)) | @as(u8, @bitCast(desc_set)));
            continue;
        }

        // this is a new entry, so let's output the old

        try output.writeAll(group_buffer[0..group_buffer_len]);
        try output.writeAll(":");
        try output.writeByte(@bitCast(desc_set));
        try output.writeAll(":");
        try output.writeAll(number_buffer[0..num_buffer_len]);
        try output.writeAll("\n");

        // save the new entry

        memcopy(group_buffer[0..], grp);
        group_buffer_len = grp.len;

        memcopy(number_buffer[0..], num);
        num_buffer_len = num.len;

        desc_set = local_desc;
    }

    if (has_buffered_entry) {
        // lets output one last entry
        try output.writeAll(group_buffer[0..group_buffer_len]);
        try output.writeAll(":");
        try output.writeByte(@bitCast(desc_set));
        try output.writeAll(":");
        try output.writeAll(number_buffer[0..num_buffer_len]);
        try output.writeAll("\n");
    }

    try output_buffer.flush();
}
