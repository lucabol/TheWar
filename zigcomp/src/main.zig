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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var w = try MultiTypeArray(soldierTypes[0..]).init(&arena.allocator, 10_000_000);
    defer w.deinit();

    var v = w.value();
    if (v != 130_000_000) std.debug.panic("{s}", .{"Wrong sum"});
}

fn initType(comptime types: []const type) type {
    comptime var fields: [types.len]builtin.TypeInfo.StructField = undefined;
    inline for (types) |st, i| {
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

pub fn MultiTypeArray(comptime types: []const type) type {
    return struct {
        const Self = @This();
        const InnerType = initType(types);

        inner: InnerType = undefined,
        ally: *Allocator = undefined,

        pub fn init(ally: *Allocator, count: u32) !Self {
            var tmp: InnerType = undefined;
            inline for (types) |st| {
                @field(tmp, @typeName(st)) = try ally.alloc(st, count);
                std.mem.set(st, @field(tmp, @typeName(st)), st.default);
            }
            return Self{
                .inner = tmp,
                .ally = ally,
            };
        }

        pub fn deinit(self: Self) void {
            inline for (types) |st| {
                self.ally.free(@field(self.inner, @typeName(st)));
            }
        }

        pub fn value(self: Self) u32 {
            var sum: u32 = 0;
            const inner = self.inner;
            inline for (types) |st| {
                for (@field(inner, @typeName(st))) |s| {
                    sum += s.value();
                }
            }
            return sum;
        }
    };
}
