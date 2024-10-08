const std = @import("std");

const default_upload_heap_capacity: u32 = 32 * 1024 * 1024;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const options = .{
        .debug_layer = b.option(
            bool,
            "debug_layer",
            "Enable debug layer",
        ) orelse false,
        .gbv = b.option(
            bool,
            "gbv",
            "Enable GPU-based validation",
        ) orelse false,
        .d2d = b.option(bool, "d2d", "Enable Direct2D") orelse false,
        .upload_heap_capacity = b.option(
            u32,
            "upload_heap_capacity",
            "Set upload heap capacity",
        ) orelse default_upload_heap_capacity,
    };

    const options_step = b.addOptions();
    inline for (std.meta.fields(@TypeOf(options))) |field| {
        options_step.addOption(field.type, field.name, @field(options, field.name));
    }

    const options_module = options_step.createModule();

    const zwin32 = b.dependency("zwin32", .{
        .target = target,
    });
    const zwin32_module = zwin32.module("root");

    _ = b.addModule("root", .{
        .root_source_file = b.path("src/zd3d12.zig"),
        .imports = &.{
            .{ .name = "zd3d12_options", .module = options_module },
            .{ .name = "zwin32", .module = zwin32_module },
        },
    });
}
