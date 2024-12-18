const std = @import("std");
const testing = std.testing;

var file_buf: [32 * 1024]u8 = undefined;

fn read(path: []const u8) !FileData {
    const f = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer f.close();
    const n = try f.readAll(&file_buf);
    return .{
        .file_data = file_buf[0..n],
    };
}

pub const FileData = struct {
    file_data: []const u8,

    pub fn is_done(self: *const FileData) bool {
        return self.file_data.len == 0;
    }

    /// returns if the space was a newline
    pub fn read_space(self: *FileData) bool {
        var n: usize = 0;
        var isNewline = true;
        while (n < self.file_data.len) : (n += 1) {
            const c = self.file_data[n];
            if (!std.ascii.isWhitespace(c)) break;
            if (c != '\n') isNewline = false;
        }

        self.file_data = self.file_data[n..];
        return isNewline;
    }

    pub fn read_number(self: *FileData, int: type) int {
        const info = @typeInfo(int);
        var out: int = 0;
        if (info.Int.signedness == .signed) {
            if (self.file_data[0] == '-') {
                var n: usize = 1;
                while (n < self.file_data.len) : (n += 1) {
                    const c = self.file_data[n];
                    if (!std.ascii.isDigit(c)) break else {
                        out = out * 10 - @as(int, @intCast(c - '0'));
                    }
                }

                self.file_data = self.file_data[n..];
                return out;
            }
        }
        var n: usize = 0;
        while (n < self.file_data.len) : (n += 1) {
            const c = self.file_data[n];
            if (!std.ascii.isDigit(c)) break else {
                out = out * 10 + @as(int, @intCast(c - '0'));
            }
        }

        self.file_data = self.file_data[n..];
        return out;
    }

    pub fn accept(self: *FileData, s: []const u8) bool {
        if (self.file_data.len < s.len) return false;
        if (std.mem.eql(u8, self.file_data[0..s.len], s)) {
            self.file_data = self.file_data[s.len..];
            return true;
        } else return false;
    }
};

pub const Timer = struct {
    timestamp: i64,

    pub fn start() Timer {
        const ts = std.time.microTimestamp();
        return .{
            .timestamp = ts,
        };
    }

    pub fn stop(self: @This()) void {
        const now = std.time.microTimestamp();
        const diff = now - self.timestamp;
        const ms = @divTrunc(diff, 1000);
        const us = @mod(diff, 1000);
        var decimals: [3]u8 = undefined;
        zeroFill(&decimals, us);
        std.debug.print("Time: {d}.{s}ms\n", .{ ms, decimals });
    }
};

/// Main function that does a benchmark if the answer is given in cmdargs
pub fn main_with_bench(Answer: type, ctx: anytype, f: fn (FileData, @TypeOf(ctx)) Answer) !void {
    var input_file: ?[]u8 = null;
    var answer_arg: ?[]u8 = null;
    if (std.os.argv.len > 1) {
        for (std.os.argv[1..]) |arg| {
            const buf = std.mem.span(arg);
            if (std.mem.endsWith(u8, buf, ".txt")) {
                input_file = buf;
            } else {
                answer_arg = buf;
            }
        }
    }

    const fd = try read(if (input_file) |p| p else "input.txt");
    if (answer_arg) |answer| {
        try benchmark(Answer, fd, answer, ctx, f);
    } else {
        const timer = Timer.start();
        const answer = f(fd, ctx);
        timer.stop();
        try std.io.getStdOut().writer().print("{any}\n", .{answer});
    }
}

pub fn benchmark(Answer: type, fd: FileData, answer: []u8, ctx: anytype, f: fn (FileData, @TypeOf(ctx)) Answer) !void {
    var timer = AvgTimer.init();
    defer timer.deinit();

    const benchmark_start = std.time.milliTimestamp();

    while (!timer.is_full() and (timer.next_time < 10 or (std.time.milliTimestamp() - benchmark_start < MAX_BENCHMARK_TIME_MS))) {
        timer.start();
        const calculated = f(fd, ctx);
        var buf: [1024]u8 = undefined;
        const printed = try std.fmt.bufPrint(&buf, "{any}", .{calculated});
        timer.stop();
        if (!std.mem.eql(u8, printed, answer)) {
            std.debug.panic("incorrect result during benchmark, got {d}\n", .{calculated});
        }
    }
}

const MAX_TIMES_TO_RUN = 10_000;
const MAX_BENCHMARK_TIME_MS = 4_800;

fn zeroFill(buf: []u8, int: anytype) void {
    var n = int;
    var p: usize = buf.len - 1;
    while (p < buf.len) {
        buf[p] = '0' + @as(u8, @intCast(@rem(n, 10)));
        n = @divTrunc(n, 10);
        p -%= 1;
    }
}

pub const AvgTimer = struct {
    timestamp: i64,
    times: [MAX_TIMES_TO_RUN]u32,
    next_time: usize = 0,

    pub fn init() AvgTimer {
        return .{
            .timestamp = undefined,
            .times = undefined,
        };
    }
    pub fn deinit(self: *AvgTimer) void {
        std.mem.sortUnstable(u32, self.times[0..self.next_time], {}, std.sort.asc(u32));
        const outlier_count = (3 * self.next_time) / 10;
        const times = self.times[outlier_count .. self.next_time - outlier_count];

        var sum: i128 = 0;
        for (times) |time| {
            sum += time;
        }
        const avg = @divTrunc(sum, @as(i64, @intCast(times.len)));
        sum = 0;
        for (times) |time| {
            const x = time - avg;
            sum += x * x;
        }
        const variance = @divTrunc(sum, @as(i64, @intCast(times.len)));

        const ms = @divTrunc(avg, 1000);
        const us = @mod(avg, 1000);
        var decimals: [3]u8 = undefined;
        zeroFill(&decimals, us);
        std.debug.print("Average time: {d}.{s}ms ± {d}µs\n", .{ ms, decimals, variance });
    }

    pub fn is_full(self: *const AvgTimer) bool {
        return self.next_time >= MAX_TIMES_TO_RUN;
    }

    /// Do not run without checking `is_full`
    pub fn start(self: *AvgTimer) void {
        const ts = std.time.microTimestamp();
        self.timestamp = ts;
    }

    /// Do not run without `start`
    pub fn stop(self: *AvgTimer) void {
        const now = std.time.microTimestamp();
        const diff = now - self.timestamp;
        self.times[self.next_time] = @intCast(diff);
        self.next_time += 1;
    }
};
