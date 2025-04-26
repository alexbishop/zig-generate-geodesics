const std = @import("std");

const memcopy = @import("./copy-util.zig").copy;

pub const DescendSet = packed struct(u8) {
    a: bool = false,
    A: bool = false,
    b: bool = false,
    B: bool = false,
    padding: u4 = 4,
};

fn str4ToInt(str: [4]u8) u32 {
    return @as(u32, @bitCast(str));
}

fn str4_0ToInt(str: *const [4:0]u8) u32 {
    return str4ToInt(str[0..4].*);
}

fn simplifySmallSubtree(buffer: []u8) bool {
    if (buffer[0] != '(') return false;
    if (buffer.len < 4) return false;
    switch (str4ToInt(buffer[1..5].*)) {
        str4_0ToInt("=111") => buffer[0] = '1',
        str4_0ToInt(">111") => buffer[0] = 'a',
        str4_0ToInt("<111") => buffer[0] = 'A',
        str4_0ToInt("=a1b") => buffer[0] = 'b',
        str4_0ToInt("=A1B") => buffer[0] = 'B',
        else => return false,
    }
    return true;
}

fn expandLetter(letter: u8) []const u8 {
    switch (letter) {
        '1' => return "(=111)",
        'a' => return "(>111)",
        'A' => return "(<111)",
        'b' => return "(=a1b)",
        'B' => return "(=A1B)",
        else => unreachable,
    }
}

fn pairToInt(lhs: u8, rhs: u8) u16 {
    return @as(u16, @intCast(lhs)) | (@as(u16, @intCast(rhs)) * 256);
}

fn multiplyLetters(lhs: u8, rhs: u8) []const u8 {
    switch (pairToInt(lhs, rhs)) {
        pairToInt('1', '1') => return "1",
        pairToInt('1', 'a') => return "a",
        pairToInt('1', 'A') => return "A",
        pairToInt('1', 'b') => return "b",
        pairToInt('1', 'B') => return "B",

        pairToInt('a', '1') => return "a",
        pairToInt('a', 'a') => return "A",
        pairToInt('a', 'A') => return "1",
        pairToInt('a', 'b') => return "(>a1b)",
        pairToInt('a', 'B') => return "(>A1B)",

        pairToInt('A', '1') => return "A",
        pairToInt('A', 'a') => return "1",
        pairToInt('A', 'A') => return "a",
        pairToInt('A', 'b') => return "(<a1b)",
        pairToInt('A', 'B') => return "(<A1B)",

        pairToInt('b', '1') => return "b",
        pairToInt('b', 'a') => return "(>ba1)",
        pairToInt('b', 'A') => return "(<1ba)",
        pairToInt('b', 'b') => return "B",
        pairToInt('b', 'B') => return "1",

        pairToInt('B', '1') => return "B",
        pairToInt('B', 'a') => return "(>BA1)",
        pairToInt('B', 'A') => return "(<1BA)",
        pairToInt('B', 'b') => return "1",
        pairToInt('B', 'B') => return "b",

        else => unreachable,
    }
}

fn matchBracketed(buffer: []const u8) []const u8 {
    if (buffer[0] != '(') {
        return buffer[0..1];
    }

    var index: usize = 1;
    var level: usize = 1;

    while (level != 0) {
        switch (buffer[index]) {
            '(' => level += 1,
            ')' => level -= 1,
            else => {},
        }
        index += 1;
    }

    return buffer[0..index];
}

const Perm = enum(u8) {
    minus = '<',
    id = '=',
    plus = '>',
    pub fn valueMod3(self: Perm) u8 {
        return switch (self) {
            .minus => 2,
            .id => 0,
            .plus => 1,
        };
    }
    pub fn fromMod3(val: u8) Perm {
        return switch (val % 3) {
            0 => .id,
            1 => .plus,
            2 => .minus,
            else => unreachable,
        };
    }
    pub fn multiply(lhs: Perm, rhs: Perm) Perm {
        return fromMod3(lhs.valueMod3() + rhs.valueMod3());
    }
};

fn matchSubtree(buffer: []const u8) struct {
    left: []const u8,
    middle: []const u8,
    right: []const u8,
    perm: Perm,
} {
    if (buffer.len < 5) unreachable;
    if (buffer[0] != '(') unreachable;

    const left_subtree = matchBracketed(buffer[2..]);
    const middle_subtree = matchBracketed(buffer[(2 + left_subtree.len)..]);
    const right_subtree = matchBracketed(buffer[(2 + left_subtree.len + middle_subtree.len)..]);

    return .{
        .left = left_subtree,
        .middle = middle_subtree,
        .right = right_subtree,
        .perm = @as(Perm, @enumFromInt(buffer[1])),
    };
}

pub fn multiply(
    buffer: []u8,
    lhs: []const u8,
    rhs: []const u8,
) ![]u8 {
    if (lhs[0] == '1') {
        const rhs_decomp = matchBracketed(rhs);
        memcopy(buffer, rhs_decomp);
        return buffer[0..rhs_decomp.len];
    }

    if (rhs[0] == '1') {
        const lhs_decomp = matchBracketed(lhs);
        memcopy(buffer, lhs_decomp);
        return buffer[0..lhs_decomp.len];
    }

    if (lhs[0] != '(' and rhs[0] != '(') {
        const result = multiplyLetters(lhs[0], rhs[0]);
        memcopy(buffer[0..result.len], result);
        return buffer[0..result.len];
    }

    if (lhs[0] == '(' and rhs[0] == '(') {
        const lhs_decomp = matchSubtree(lhs);
        const rhs_decomp = matchSubtree(rhs);

        buffer[0] = '(';
        buffer[1] = @intFromEnum(Perm.multiply(
            lhs_decomp.perm,
            rhs_decomp.perm,
        ));

        switch (rhs_decomp.perm) {
            .id => {
                const l_result = try multiply(
                    buffer[2..],
                    lhs_decomp.left,
                    rhs_decomp.left,
                );
                const m_result = try multiply(
                    buffer[(2 + l_result.len)..],
                    lhs_decomp.middle,
                    rhs_decomp.middle,
                );
                const r_result = try multiply(
                    buffer[(2 + l_result.len + m_result.len)..],
                    lhs_decomp.right,
                    rhs_decomp.right,
                );
                buffer[2 + l_result.len + m_result.len + r_result.len] = ')';

                const could_simplify = simplifySmallSubtree(buffer);
                if (could_simplify) {
                    return buffer[0..1];
                } else {
                    return buffer[0..(2 + l_result.len + m_result.len + r_result.len + 1)];
                }
            },
            .plus => {
                const l_result = try multiply(
                    buffer[2..],
                    lhs_decomp.right,
                    rhs_decomp.left,
                );
                const m_result = try multiply(
                    buffer[(2 + l_result.len)..],
                    lhs_decomp.left,
                    rhs_decomp.middle,
                );
                const r_result = try multiply(
                    buffer[(2 + l_result.len + m_result.len)..],
                    lhs_decomp.middle,
                    rhs_decomp.right,
                );
                buffer[2 + l_result.len + m_result.len + r_result.len] = ')';

                const could_simplify = simplifySmallSubtree(buffer);
                if (could_simplify) {
                    return buffer[0..1];
                } else {
                    return buffer[0..(2 + l_result.len + m_result.len + r_result.len + 1)];
                }
            },
            .minus => {
                const l_result = try multiply(
                    buffer[2..],
                    lhs_decomp.middle,
                    rhs_decomp.left,
                );
                const m_result = try multiply(
                    buffer[(2 + l_result.len)..],
                    lhs_decomp.right,
                    rhs_decomp.middle,
                );
                const r_result = try multiply(
                    buffer[(2 + l_result.len + m_result.len)..],
                    lhs_decomp.left,
                    rhs_decomp.right,
                );
                buffer[2 + l_result.len + m_result.len + r_result.len] = ')';

                const could_simplify = simplifySmallSubtree(buffer);
                if (could_simplify) {
                    return buffer[0..1];
                } else {
                    return buffer[0..(2 + l_result.len + m_result.len + r_result.len + 1)];
                }
            },
        }
    }

    if (rhs[0] == '(') {
        return multiply(
            buffer,
            expandLetter(lhs[0]),
            rhs,
        );
    } else {
        return multiply(
            buffer,
            lhs,
            expandLetter(rhs[0]),
        );
    }
}
