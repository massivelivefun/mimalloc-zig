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

pub var mi_page_flags_t = mi_page_flags_s;
// this union needs a bitfield version
const mi_page_flags_s = union {
    full_aligned: u8,
    x = struct {
        in_full: u8,
        has_aligned: u8,
    },
};

const mi_thread_free_t = usize;

pub const mi_page_t = mi_page_s;
const mi_page_s = struct {
    segment_idx: u8,
    // start: u8 bitfield
    segment_in_use: u8,
    is_reset: u8,
    is_committed: u8,
    is_zero_init: u8,
    // end

    capacity: u16,
    reserved: u16,
    flags: mi_page_flags_t,
    // start: u8 bitfield
    is_zero: u8, // : 1
    retire_expire: u8 // : 7
    // end

    free: *mi_block_t,
    // start: need additional mi_encode_freelist version struct
    keys: [2]usize,
    // end
    used: u32,
    xblock_size: u32,

    local_free: *mi_block_t,
    xthread_free: mi_thread_free_t, // type needs to be wrapped in _Atomic zig equiv
    xheap: usize, // type needs to be wrapped in _Atomic zig equiv

    next: *mi_page_s,
    prev: *mi_page_s,
};

pub const mi_page_kind_t = mi_page_kind_e;
const mi_page_kind_e = enum {
    mi_page_small,
    mi_page_medium,
    mi_page_large,
    mi_page_huge,
};

pub const mi_segment_t = mi_segment_s;
const mi_segment_s = struct {
    // memory fields
    memid: usize,
    mem_is_pinned: bool,
    mem_is_committed: bool,

    // segment fields
    abandoned_next: *mi_segment_s, // type needs to be _Atomic
    next: *mi_segment_s,
    prev: *mi_segment_s,

    abandoned: usize,
    abandoned_visits: usize,

    used: usize,
    capacity: usize,
    segment_size: usize,
    segment_info_size: usize,
    cookie: usize,

    // layout like this to optimize access in `mi_free`
    page_shift: usize,
    thread_id: usize, // type needs to be _Atomic
    page_kind: mi_page_kind_t,
    pages: [1]mi_page_t,
};

pub const mi_page_queue_t = mi_page_queue_s;
const mi_page_queue_s = struct {
    first: *mi_page_t,
    last: *mi_page_t,
    block_size: usize,
};

const mi_bin_full = mi_bin_huge + 1;

pub const mi_random_ctx_t = mi_random_ctx_s;
const mi_random_ctx_s = struct {
    input: [16]u32,
    output: [16]u32,
    output_available: c_int,
};

// start: there's a bunch of build stuff that needs to happen for this type
pub const mi_padding_t = mi_padding_s;
const mi_padding_s = struct {
    canary: u32,
    delta: u32,
};

const mi_padding_size = 0;
const mi_padding_wsize = 0;
// end

const mi_pages_direct = mi_small_wsize_max + mi_padding_wsize + 1;

pub const mi_heap_t = mi_heap_s;
const mi_heap_s = struct {
    tld: *mi_tld_t,
    page: [mi_pages_direct]*mi_page_t,
    mi_page_queue: [mi_bin_full + 1]mi_page_queue_t,
    thread_delayed_free: *mi_block_t,   // type needs to be _Atomic
    thread_id: usize,
    cookie: usize,
    keys: [2]usize,
    random: mi_random_ctx_t,
    page_count: usize,
    page_retired_min: usize,
    page_retired_max: usize,
    next: *mi_heap_t,
    no_reclaim: bool,
};

pub const mi_stat_count_t = mi_stat_count_s;
const mi_stat_count_s = struct {
    allocated: i64,
    freed: i64,
    peak: i64,
    current: i64,
};

pub const mi_stat_counter_t = mi_stat_counter_s;
const mi_stat_counter_s = struct {
    total: i64,
    count: i64,
};

pub const mi_stats_t = mi_stats_s;
const mi_stats_s = struct {
    segments: mi_stat_count_t,
    pages: mi_stat_count_t,
    reserved: mi_stat_count_t,
    committed: mi_stat_count_t,
    reset: mi_stat_count_t,
    page_committed: mi_stat_count_t,
    segments_abandoned: mi_stat_count_t,
    pages_abandoned: mi_stat_count_t,
    threads: mi_stat_count_t,
    normal: mi_stat_count_t,
    huge: mi_stat_count_t,
    giant: mi_stat_count_t,
    malloc: mi_stat_count_t,
    segments_cache: mi_stat_count_t,
    pages_extended: mi_stat_counter_t,
    mmap_calls: mi_stat_counter_t,
    commit_calls: mi_stat_counter_t,
    page_no_retire: mi_stat_counter_t,
    searches: mi_stat_counter_t,
    normal_count: mi_stat_counter_t,
    huge_count: mi_stat_counter_t,
    giant_count: mi_stat_counter_t,
    // need to probably make another struct and make the build.zig wrap this
    // start: if MI_STAT > 1
    // normal_bins: [mi_bin_huge + 1]mi_stat_count_t
    // end
};

// A bunch of function wrappers based on macros

pub const mi_msecs_t = i64;

pub const mi_segment_queue_t = mi_segment_queue_s;
const mi_segment_queue_s = struct {
    first: *mi_segment_t,
    last: *mi_segment_t,
};

pub const mi_os_tld_t = mi_os_tld_s;
const mi_os_tld_s = struct {
    region_idx: usize,
    stats: *mi_stats_t,
};

pub const mi_segments_tld_t = mi_segments_tld_s;
const mi_segments_tld_s = struct {
    small_free: mi_segment_queue_t,
    medium_free: mi_segment_queue_t,
    pages_reset: mi_page_queue_t,
    count: usize,
    peak_count: usize,
    current_size: usize,
    peak_size: usize,
    cache_count: usize,
    cache_size: usize,
    cache: *mi_segment_t,
    stats: *mi_stats_t,
    os: *mi_os_tld_t,
};

pub const mi_tld_t = mi_tld_s;
const mi_tld_s = struct {
    heartbeat: c_ulonglong,
    recurse: bool,
    heap_backing: *mi_heap_t,
    heaps: *mi_heap_t,
    os: mi_os_tld_t,
    stats: mi_stats_t,
};
