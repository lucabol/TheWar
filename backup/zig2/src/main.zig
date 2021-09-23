const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Man = struct { strength: u32, stamina: u32 };
const Elf = struct { age: u32, magic: u32 };
const Dwarf = struct { will: u32 };

const WarSystem = struct {
    men: ArrayList(Man),
    elves: ArrayList(Elf),
    dwarves: ArrayList(Dwarf),

    pub fn init(ally: *Allocator, soldiers: u32) !WarSystem {
        var _men = try ArrayList(Man).initCapacity(ally, soldiers / 3);
        var _elves = try ArrayList(Elf).initCapacity(ally, soldiers / 3);
        var _dwarves = try ArrayList(Dwarf).initCapacity(ally, soldiers / 3);

        _men.appendNTimesAssumeCapacity(Man{ .strength = 1, .stamina = 1 }, soldiers / 3);
        _elves.appendNTimesAssumeCapacity(Elf{ .age = 1, .magic = 1 }, soldiers / 3);
        _dwarves.appendNTimesAssumeCapacity(Dwarf{ .will = 1 }, soldiers / 3);

        return WarSystem{
            .men = _men,
            .elves = _elves,
            .dwarves = _dwarves,
        };
    }

    pub fn deinit(self: WarSystem) void {
        self.men.deinit();
        self.elves.deinit();
        self.dwarves.deinit();
    }

    pub fn ValueArmy(self: WarSystem) u32 {
        var sum: u32 = 0;
        for (self.men.items) |s| {
            sum += s.strength * s.stamina;
        }
        for (self.elves.items) |s| {
            sum += s.age * s.magic * 2;
        }
        for (self.dwarves.items) |s| {
            sum += s.will * 10;
        }
        return sum;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var ally = &arena.allocator;

    var w = try WarSystem.init(ally, 3_000_000);
    defer w.deinit();

    var v = w.ValueArmy();
    if (v != 13_000_000) std.debug.panic("{s}", .{"Wrong sum"});
}
