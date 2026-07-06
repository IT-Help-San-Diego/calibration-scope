const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "archetype-mesh-dashboard",
        .root_module = module,
        .linkage = .static,
        .use_llvm = true,
        .use_lld = true,
    });

    exe.linkLibC();
    exe.linkSystemLibrary("sqlite3");

    b.installArtifact(exe);
}
