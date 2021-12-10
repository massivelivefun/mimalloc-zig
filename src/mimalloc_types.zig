// start: This needs to be tied into the build.zig mechanisms

pub var mi_max_align_size = 16;

pub var mi_secure = 0;

pub var mi_debug = 0;

pub var mi_padding = 1;

pub var mi_encode_freelist = 1;

pub var mi_intptr_shift = 3;

pub var mi_intptr_size = 1 << mi_intptr_shift;

pub var mi_intptr_bits = mi_intptr_size * 8;

pub const KiB = @as(usize, 1024);
pub const MiB = KiB * KiB;
pub const GiB = MiB * KiB;

pub var mi_small_page_shift = 13 + mi_intptr_shift;
pub var mi_medium_page_shift = 3 + mi_small_page_shift;
pub var mi_large_page_shift = 3 + mi_medium_page_shift;
pub var mi_segment_shift = mi_large_page_shift;

pub var mi_segment_size = @as(usize, 1) << mi_segment_shift;
pub var mi_segment_mask = @as(usize, mi_segment_size - 1);

pub var mi_small_page_size = @as(usize, 1) << mi_small_page_shift;
pub var mi_medium_page_size = @as(usize, 1) << mi_medium_page_shift;
pub var mi_large_page_size = @as(usize, 1) << mi_large_page_shift;

pub var mi_small_pages_per_segment = mi_segment_size / mi_small_page_size;
pub var mi_medium_pages_per_segment = mi_segment_size / mi_medium_page_size;
pub var mi_large_pages_per_segment = mi_segment_size / mi_large_page_size;

pub var mi_small_obj_size_max = mi_small_page_size / 4;
pub var mi_medium_obj_size_max = mi_medium_page_size / 4;
pub var mi_large_obj_size_max = mi_large_page_size / 4;
pub var mi_large_obj_wsize_max = mi_large_obj_size_max / mi_intptr_size;
pub var mi_huge_obj_size_max = 2 * mi_intptr_size * mi_sigment_size;

pub var mi_bin_huge = 73;

if (mi_large_obj_wsize_max >= 655360) {
    // throw build error
}

pub var mi_huge_block_size = @as(u32, mi_huge_obj_size_max);

// end

const mi_encoded_t = usize;

pub const mi_block_t = mi_block_e;
const mi_block_e = struct {
    next: mi_encoded_t,
};

pub const mi_delayed_t = mi_delayed_e;
const mi_delayed_e = enum {
    mi_use_delayed_free,
    mi_delayed_freeing,
    mi_no_delayed_freeing,
    mi_never_delayed_free,
};

const mi_thread_free_t = usize;

pub const mi_page_kind_t = mi_page_kind_e;
const mi_page_kind_e = enum {
    mi_page_small,
    mi_page_medium,
    mi_page_large,
    mi_page_huge,
};

pub const mi_random_ctx_t = mi_random_ctx_s;
const mi_random_ctx_s = struct {
    input: [16]u32,
    output: [16]u32,
    output_available: c_int,
}

pub const mi_stat_count_t = mi_stat_count_s;
const mi_stat_count_s = struct {
    allocated: isize,
    freed: isize,
    peak: isize,
    current: isize,
};

pub const mi_stat_counter_t = mi_stat_counter_s;
const mi_stat_counter_s = struct {
    total: isize,
    count: isize,
};