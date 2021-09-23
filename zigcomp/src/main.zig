const std = @import("std");
const builtin = @import("std").builtin;
const Allocator = std.mem.Allocator;

// Each type added to the array below must have a `default` and `value` members,
// Otherwise a compile time error is generated.
// Compile-time arrays of these types are created *automatically* to make calculations
// of value across all the soldiers cache friendly. Automatically deinit generated.
const soldierTypes = [_]type{ Man, Elf, Dwarf };

const Man = struct {
    strength: u32,
    stamina: u32,

    const default = Man{ .strength = 1, .stamina = 1 };
    pub fn value(self: Man) u32 {
        return self.strength * self.stamina;
    }
};
const Elf = struct {
    age: u32,
    magic: u32,

    const default = Elf{ .age = 1, .magic = 1 };
    pub fn value(self: Elf) u32 {
        return self.age * self.magic * 2;
    }
};
const Dwarf = struct {
    will: u32,

    const default = Dwarf{ .will = 1 };
    pub fn value(self: Dwarf) u32 {
        return self.will * 10;
    }
};

const WarSystem = struct {
    inner: WarType,
    ally: *Allocator,

    fn initType() type {
        comptime var fields: [soldierTypes.len]builtin.TypeInfo.StructField = undefined;
        inline for (soldierTypes) |st, i| {
            fields[i].name = @typeName(st);
            fields[i].field_type = []st;
            fields[i].default_value = null;
            fields[i].is_comptime = false;
            fields[i].alignment = 0;
        }
        return @Type(.{
            .Struct = .{
                .layout = .Auto,
                .fields = &fields,
                .decls = &[_]builtin.TypeInfo.Declaration{},
                .is_tuple = false,
            },
        });
    }

    const WarType = initType();

    pub fn init(ally: *Allocator, soldiers: u32) !WarSystem {
        var value: WarType = undefined;

        inline for (soldierTypes) |st| {
            @field(value, @typeName(st)) = try ally.alloc(st, soldiers / 3);
            std.mem.set(st, @field(value, @typeName(st)), st.default);
        }
        return WarSystem{ .inner = value, .ally = ally };
    }

    pub fn deinit(self: WarSystem) void {
        inline for (soldierTypes) |st| {
            self.ally.free(@field(self.inner, @typeName(st)));
        }
    }

    pub fn valueArmy(self: WarSystem) u32 {
        _ = self;
        var sum: u32 = 0;
        const inner = self.inner;
        inline for (soldierTypes) |st| {
            for (@field(inner, @typeName(st))) |s| {
                sum += s.value();
            }
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
