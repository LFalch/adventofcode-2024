const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var f = try aoc.read_input();
    const timer = aoc.Timer.start();

    var numSafe: u64 = 0;

    big: while (!f.is_done()) {
        std.debug.print("\n", .{});
        var list = std.ArrayList(i8).init(alloc);
        defer list.deinit();

        var newLine = false;
        while (!newLine) : (newLine = f.read_space()) {
            try list.append(@intCast(f.read_number(u8)));
        }

        for (list.items[1..], 0..) |e, i| {
            const d = e - list.items[i];
            list.items[i] = d;
            std.debug.print("{d} ", .{d});
        }
        list.items.len -= 1;

        var posses: u16 = 0;
        var negs: u16 = 0;
        var tooBig: ?i8 = null;
        var negN: ?i8 = null;
        var posN: ?i8 = null;

        for (list.items) |l| {
            if (@abs(l) > 3) {
                if (tooBig) |tb| {
                    std.debug.print("  .{d}", .{tb});
                    continue :big;
                }
                tooBig = l;
            }
            if (l > 0) {
                posN = l;
                posses += 1;
            } else if (l < 0) {
                negN = l;
                negs += 1;
            }
        }
        if (tooBig) |n| {
            if (n < 0) {
                switch (posses) {
                    0 => {},
                    1 => if (negN != n) continue :big,
                    else => continue :big,
                }
            } else if (n > 0) {
                switch (negs) {
                    0 => {},
                    1 => if (posN != n) continue :big,
                    else => continue :big,
                }
            }
        }

        if ((posses >= 0 and negs <= 1) or (negs >= 0 and posses <= 1)) {
            numSafe += 1;
            std.debug.print(" x", .{});
        }
    }
    timer.stop();
    try std.io.getStdOut().writer().print("{d}\n", .{numSafe});
    // 398
}

// handle the fact that an outlier diff needs to be replaced by summing it with the next
// diff in order to get the correct diff
