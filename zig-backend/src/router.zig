const std = @import("std");

pub const Route = struct {
    method: []const u8,
    path: []const u8,
    handler: *const fn (*std.http.Server.Response, *std.mem.Allocator) anyerror!void,
};

pub fn match(method: []const u8, path: []const u8, routes: []const Route) ?*const fn (*std.http.Server.Response, *std.mem.Allocator) anyerror!void {
    for (routes) |route| {
        if (std.mem.eql(u8, method, route.method) and std.mem.eql(u8, path, route.path)) {
            return route.handler;
        }
    }
    return null;
}
