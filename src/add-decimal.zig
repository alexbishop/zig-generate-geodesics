const std = @import("std");

pub fn add(
    buffer: []u8,
    lhs: []const u8,
    rhs: []const u8,
) []u8 {
    if (lhs.len < rhs.len) return add(buffer, rhs, lhs);

    var carry: u8 = 0;

    for (0..rhs.len) |i| {
        const l_num = lhs[lhs.len - i - 1] - '0';
        const r_num = rhs[rhs.len - i - 1] - '0';

        const result = l_num + r_num + carry;
        carry = if (result > 9) 1 else 0;
        buffer[i] = (result % 10) + '0';
    }

    for (rhs.len..lhs.len) |i| {
        const l_num = lhs[lhs.len - i - 1] - '0';

        const result = l_num + carry;
        carry = if (result > 9) 1 else 0;
        buffer[i] = (result % 10) + '0';
    }

    if (carry == 1) {
        buffer[lhs.len] = '1';
        std.mem.reverse(u8, buffer[0..(lhs.len + 1)]);
        return buffer[0..(lhs.len + 1)];
    } else {
        std.mem.reverse(u8, buffer[0..lhs.len]);
        return buffer[0..lhs.len];
    }
}
