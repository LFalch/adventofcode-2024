const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const aoc = b.addModule("aoc", .{
        .root_source_file = b.path("../zig-utils/src/root.zig"),
        .optimize = optimize,
    });

    const part1 = b.addExecutable(.{
        .name = "part1",
        .root_source_file = b.path("src/part1.zig"),
        .target = target,
        .optimize = optimize,
    });
    part1.root_module.addImport("aoc", aoc);
    const part2 = b.addExecutable(.{
        .name = "part2",
        .root_source_file = b.path("src/part2.zig"),
        .target = target,
        .optimize = optimize,
    });
    part2.root_module.addImport("aoc", aoc);

    b.installArtifact(part1);
    b.installArtifact(part2);

    const run_cmd1 = b.addRunArtifact(part1);
    const run_cmd2 = b.addRunArtifact(part2);

    run_cmd1.step.dependOn(b.getInstallStep());
    run_cmd2.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd1.addArgs(args);
        run_cmd2.addArgs(args);
    }

    const run_step1 = b.step("run1", "Run part 1");
    run_step1.dependOn(&run_cmd1.step);
    const run_step2 = b.step("run2", "Run part 2");
    run_step2.dependOn(&run_cmd2.step);
}
