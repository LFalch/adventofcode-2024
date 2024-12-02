const std = @import("std");

var lineDoneNext = false;

pub fn read_num(reader: anytype) !?u8 {
    if (lineDoneNext) {
        lineDoneNext = false;
        return null;
    }

    var buf: [128]u8 = undefined;
    var i: usize = 0;

    while (true) {
        const b = try reader.readByte();

        switch (b) {
            '\n' => {
                lineDoneNext = true;
                break;
            },
            ' ' => break,
            else => {
                buf[i] = b;
                i += 1;
            },
        }
    }
    return try std.fmt.parseInt(u8, buf[0..i], 10);
}
