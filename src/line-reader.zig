const std = @import("std");

const memcopy = @import("./copy-util.zig").copy;

pub fn LineReader(
    comptime input_buffer_size: usize,
    comptime line_buffer_size: usize,
) type {
    return struct {
        input_buffer: [input_buffer_size]u8,
        input_buffer_used: usize,
        input_buffer_offset: usize,
        line_buffer: [line_buffer_size]u8,
        file: std.fs.File,
        reached_eof: bool,

        pollfs_list: [1]std.posix.pollfd,

        pub fn init(self: *@This(), path: [:0]const u8) !void {
            const file = try std.fs.cwd().openFileZ(path, .{});
            return self.initWithFile(file);
        }

        pub fn initWithFile(self: *@This(), file: std.fs.File) void {
            self.input_buffer_used = 0;
            self.reached_eof = false;
            self.file = file;
            self.pollfs_list[0] = std.posix.pollfd{
                .fd = self.file.handle,
                .events = std.posix.POLL.IN,
                .revents = 0,
            };
        }

        pub fn deinit(self: *@This()) void {
            self.file.close();
        }

        fn fillWithPoll(self: *@This()) !void {
            // see if there are more chunks to read
            while (self.input_buffer_used < input_buffer_size) {
                // check if there is anything to read
                const result = std.posix.system.poll(&self.pollfs_list, 1, 1);
                if (result != 1) {
                    // there was an error during poll or we have nothing to read
                    return;
                }
                if ((self.pollfs_list[0].revents & std.posix.POLL.IN) != std.posix.POLL.IN) {
                    // there was nothing ready to read from the pipe
                    return;
                }
                const new_size = try self.file.read(self.input_buffer[self.input_buffer_used..]);
                if (new_size == 0) {
                    self.reached_eof = true;
                    return;
                }
                self.input_buffer_used += new_size;
            }
        }

        fn getBuffered(self: *@This()) !?[]u8 {
            if (self.input_buffer_used > 0 and self.input_buffer_offset < self.input_buffer_used) {
                try self.fillWithPoll();
                return self.input_buffer[self.input_buffer_offset..self.input_buffer_used];
            }

            if (self.reached_eof) {
                return null;
            }

            // read the first chunk
            const size = try self.file.read(self.input_buffer[0..]);
            if (size == 0) {
                self.reached_eof = true;
                return null;
            }
            self.input_buffer_used = size;
            self.input_buffer_offset = 0;

            try self.fillWithPoll();

            return self.input_buffer[0..self.input_buffer_used];
        }

        pub fn next(self: *@This()) !?[]const u8 {
            var len: usize = 0;

            var buffered: []u8 = (try self.getBuffered()) orelse {
                return null;
            };

            while (true) {
                const index = std.mem.indexOfScalar(u8, buffered, '\n');

                if (index != null) {
                    memcopy(self.line_buffer[len..], buffered[0..index.?]);
                    self.input_buffer_offset += index.? + 1;
                    len += index.?;
                    return self.line_buffer[0..len];
                }

                memcopy(self.line_buffer[len..], buffered);
                len += buffered.len;
                self.input_buffer_used = 0;

                buffered = (try self.getBuffered()) orelse {
                    return self.line_buffer[0..len];
                };
            }
        }
    };
}
