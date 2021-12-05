const MI_CHACHA_ROUNDS = 20;

fn rotl(x: u32, shift: u32) callconv(.Inline) u32 {
    // can't just bitshift in Zig, i need to look into this
    return (x << shift) | (x >> (32 - shift));
}

fn qround(x: u32[16], a: usize, b: usize, c: usize, d: usize) {
    x[a] += [b];
    x[d] = rotl(x[d] ^ x[a], 16);
    x[c] += x[d];
    x[b] = rotl(x[b] ^ x[c], 12);
}
