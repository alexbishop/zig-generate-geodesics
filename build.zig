const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    {
        const exe_mod_prepend_fg = b.createModule(.{
            .root_source_file = b.path("src/main-prepend-generator-fg.zig"),
            .target = target,
            .optimize = optimize,
        });
        const exe_prepend_fg = b.addExecutable(.{
            .name = "prepend-generator-fg",
            .root_module = exe_mod_prepend_fg,
        });
        b.installArtifact(exe_prepend_fg);
    }

    {
        const exe_mod_unique = b.createModule(.{
            .root_source_file = b.path("src/main-make-unique.zig"),
            .target = target,
            .optimize = optimize,
        });
        const exe_unique = b.addExecutable(.{
            .name = "make-unique",
            .root_module = exe_mod_unique,
        });
        b.installArtifact(exe_unique);
    }

    {
        const exe_mod_subtract = b.createModule(.{
            .root_source_file = b.path("src/main-subtract-elements.zig"),
            .target = target,
            .optimize = optimize,
        });
        const exe_subtract = b.addExecutable(.{
            .name = "subtract-elements",
            .root_module = exe_mod_subtract,
        });
        b.installArtifact(exe_subtract);
    }

    {
        const exe_mod_summary = b.createModule(.{
            .root_source_file = b.path("src/main-summary.zig"),
            .target = target,
            .optimize = optimize,
        });
        const exe_summary = b.addExecutable(.{
            .name = "summary",
            .root_module = exe_mod_summary,
        });
        b.installArtifact(exe_summary);
    }

    {
        const exe_mod_wcbytes = b.createModule(.{
            .root_source_file = b.path("src/main-wcbytes.zig"),
            .target = target,
            .optimize = .ReleaseFast,
        });
        const exe_wcbytes = b.addExecutable(.{
            .name = "wcbytes",
            .root_module = exe_mod_wcbytes,
        });
        b.installArtifact(exe_wcbytes);
    }

    b.installFile("scripts/run.sh", "bin/run.sh");
}
