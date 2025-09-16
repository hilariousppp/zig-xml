const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    {
        const exe = b.addExecutable(.{
            .name = "bench",
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = mode,
        });

        const run_exe = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_exe.addArgs(args);
        }

        const run_step = b.step("run", "Run benchmark");
        run_step.dependOn(&run_exe.step);
    }

    const lib_module = b.addModule("zig-xml", .{
        .root_source_file = b.path("mod.zig"),
        .target = target,
        .optimize = mode,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zig-xml",
        .root_module = lib_module,
    });

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("test.zig"),
        .target = target,
        .optimize = mode,
    });

    b.installArtifact(lib);

    unit_tests.root_module.addImport("xml", lib_module);

    const run_unit_tests = b.addRunArtifact(unit_tests);
    run_unit_tests.has_side_effects = true;

    const test_step = b.step("test", "Run all library tests");
    test_step.dependOn(&run_unit_tests.step);
}
