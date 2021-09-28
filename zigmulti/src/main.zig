const std = @import("std");
const builtin = @import("std").builtin;
const Allocator = std.mem.Allocator;

const Man = packed struct {
    strength: u4,
    stamina: u4,

    const default = Man{ .strength = 1, .stamina = 1 };
    pub fn value(self: Man) u32 {
        return self.strength * self.stamina;
    }
};
const Elf = packed struct {
    age: u4,
    magic: u4,

    const default = Elf{ .age = 1, .magic = 1 };
    pub fn value(self: Elf) u32 {
        return self.age * self.magic * 2;
    }
};
const Dwarf = packed struct {
    will: u4,

    const default = Dwarf{ .will = 1 };
    pub fn value(self: Dwarf) u32 {
        return self.will * 10;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var ally = &arena.allocator;

    var w = std.MultiArrayList(struct { man: Man, elf: Elf, dwarf: Dwarf }){};
    try w.resize(ally, 10_000_000);
    defer w.deinit(ally);

    var sl = w.slice();
    defer sl.deinit(ally);

    std.mem.set(Man, sl.items(.man), Man.default);
    std.mem.set(Elf, sl.items(.elf), Elf.default);
    std.mem.set(Dwarf, sl.items(.dwarf), Dwarf.default);

    var v: u32 = 0;
    for (sl.items(.man)) |s| v += s.value();
    for (sl.items(.elf)) |s| v += s.value();
    for (sl.items(.dwarf)) |s| v += s.value();
    if (v != 130_000_000) std.debug.panic("{s}", .{"Wrong sum"});
}
