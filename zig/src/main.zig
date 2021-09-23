const std = @import("std");
const Allocator = std.mem.Allocator;

const Man = struct { strength: u32, stamina: u32 };
const Elf = struct { age: u32, magic: u32 };
const Dwarf = struct { will: u32 };

const WarSystem = struct {
    men: []Man,
    elves: []Elf,
    dwarves: []Dwarf,
    ally: *Allocator,

    pub fn init(ally: *Allocator, soldiers: u32) !WarSystem {
        const _men = try ally.alloc(Man, soldiers / 3);
        const _elves = try ally.alloc(Elf, soldiers / 3);
        const _dwarves = try ally.alloc(Dwarf, soldiers / 3);

        std.mem.set(Man, _men, .{ .strength = 1, .stamina = 1 });
        std.mem.set(Elf, _elves, .{ .age = 1, .magic = 1 });
        std.mem.set(Dwarf, _dwarves, .{ .will = 1 });

        return WarSystem{
            .ally = ally,
            .men = _men,
            .elves = _elves,
            .dwarves = _dwarves,
        };
    }

    pub fn deinit(self: WarSystem) void {
        self.ally.free(self.men);
        self.ally.free(self.elves);
        self.ally.free(self.dwarves);
    }

    pub fn valueArmy(self: WarSystem) u32 {
        var sum: u32 = 0;
        for (self.men) |s| {
            sum += s.strength * s.stamina;
        }
        for (self.elves) |s| {
            sum += s.age * s.magic * 2;
        }
        for (self.dwarves) |s| {
            sum += s.will * 10;
        }
        return sum;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var w = try WarSystem.init(&arena.allocator, 3_000_000);
    defer w.deinit();

    var v = w.valueArmy();
    if (v != 13_000_000) std.debug.panic("{s}", .{"Wrong sum"});
}
