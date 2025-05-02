const std = @import("std");

const LineReader = @import("./line-reader.zig").LineReader(1024 * 1024, 1024 * 1024);

var input_lines: LineReader = undefined;

var sub_lines: [3]LineReader = undefined;
var sub_lines_grp: [3]?[]const u8 = undefined;

var number_of_subs: u8 = undefined;

fn getSubtractionGroups() !void {
    for (0..number_of_subs) |i| {
        // fill in the sublines which are empty
        if (sub_lines_grp[i] == null) {
            while (try sub_lines[i].next()) |line| {
                // get the next line that contains a : and store the left of the :
                const split: usize = std.mem.indexOfScalar(u8, line, ':') orelse continue;
                sub_lines_grp[i] = line[0..split];
                break;
            }
        }
    }
}

pub fn main() !void {
    if (std.os.argv.len < 2 or std.os.argv.len > 4) {
        return error.IncorrectInput;
    }

    // ready our input file to subtract from
    input_lines.initWithFile(std.io.getStdIn());
    // defer input_lines.deinit();

    // output
    var std_out = std.io.getStdOut();
    var output_buffer = std.io.bufferedWriter(std_out.writer());
    var output = output_buffer.writer();

    number_of_subs = 0;
    defer {
        for (0..number_of_subs) |i| {
            sub_lines[i].deinit();
        }
    }

    for (std.os.argv, 0..) |arg, i| {
        // skip the first
        if (i == 0) continue;
        // add the file to be processed
        try sub_lines[number_of_subs].init(std.mem.span(arg));
        number_of_subs += 1;
    }

    // make sure to get the first lines of each subfile first

    // now we're ready to process
    outer: while (try input_lines.next()) |in_line| {
        const split: usize = std.mem.indexOfScalar(u8, in_line, ':') orelse continue;
        const in_group = in_line[0..split];

        // align the subtraction groups
        {
            var okay: bool = false;
            while (!okay) {
                // let's assume that everything will be okay at the end
                okay = true;

                try getSubtractionGroups();

                // let's check if everything is okay
                for (0..number_of_subs) |i| {
                    if (sub_lines_grp[i]) |tabu_group| {
                        switch (std.mem.order(u8, in_group, tabu_group)) {
                            .lt => {
                                // this is okay
                            },
                            .gt => {
                                // our tabu list is not aligned
                                sub_lines_grp[i] = null;
                                okay = false;
                            },
                            .eq => {
                                // this in_group should not appear in the output
                                continue :outer;
                            },
                        }
                    }
                }
            }
        }

        // we're all good to output this one
        try output.writeAll(in_line);
        try output.writeAll("\n");
    }

    try output_buffer.flush();
}
