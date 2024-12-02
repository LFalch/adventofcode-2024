const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const aoc = b.addModule("aoc", .{
        .root_source_file = b.path("../zig-utils/src/root.zig"),
        .optimize = optimize,
    });

    const part1 = b.addExecutable(.{
        .name = "day01_1",
        .root_source_file = b.path("src/part1.zig"),
        .target = target,
        .optimize = optimize,
    });
    part1.root_module.addImport("aoc", aoc);
    const part2 = b.addExecutable(.{
        .name = "day01_2",
        .root_source_file = b.path("src/part2.zig"),
        .target = target,
        .optimize = optimize,
    });
    part2.root_module.addImport("aoc", aoc);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(part1);
    b.installArtifact(part2);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd1 = b.addRunArtifact(part1);
    const run_cmd2 = b.addRunArtifact(part2);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd1.step.dependOn(b.getInstallStep());
    run_cmd2.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd1.addArgs(args);
        run_cmd2.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step1 = b.step("run1", "Run part 1");
    run_step1.dependOn(&run_cmd1.step);
    const run_step2 = b.step("run2", "Run part 2");
    run_step2.dependOn(&run_cmd2.step);
}
