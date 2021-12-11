const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("mimalloc-zig", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    const main_tests = b.addTests("src/tests.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependon(&main_tests.step);
}
