const std = @import("std");
const Sha3_256 = std.crypto.sha3.Sha3_256;

pub fn hashRunPayload(allocator: *std.mem.Allocator, payload: []const u8) ![]u8 {
    var out: [Sha3_256.digest_length]u8 = undefined;
    Sha3_256.hash(payload, &out, .{});
    return try allocator.dupe(u8, &out);
}
