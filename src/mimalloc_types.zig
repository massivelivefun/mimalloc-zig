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
