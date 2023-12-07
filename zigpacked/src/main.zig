const std = @import("std");
const builtin = @import("std").builtin;
const Allocator = std.mem.Allocator;

// Each type added to the array below must have a `default` and `value` members,
// Otherwise a compile time error is generated.
// Compile-time arrays of these types are created *automatically* to make calculations
// of value across all the soldiers cache friendly. Automatically deinit generated.
const soldierTypes = [_]type{ Man, Elf, Dwarf };

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

    var w = try MultiTypeArray(soldierTypes[0..]).init(&arena.allocator(), 10_000_000);
    defer w.deinit();

    var v = w.value(u32);
    if (v != 130_000_000) std.debug.panic("{s}", .{"Wrong sum"});
}

fn initType(comptime types: []const type) type {
    comptime var fields: [types.len]builtin.Type.StructField = undefined;
    inline for (types, 0..) |st, i| {
        fields[i].name = @typeName(st);
        fields[i].type = []st;
        fields[i].default_value = null;
        fields[i].is_comptime = false;
        fields[i].alignment = 0;
    }
    return @Type(.{
        .Struct = .{
            .layout = .Auto,
            .fields = &fields,
            .decls = &[_]builtin.Type.Declaration{},
            .is_tuple = false,
        },
    });
}

pub fn MultiTypeArray(comptime types: []const type) type {
    return struct {
        const Self = @This();
        const InnerType = initType(types);

        inner: InnerType = undefined,
        ally: *const Allocator = undefined,

        pub fn init(ally: *const Allocator, count: u32) !Self {
            var tmp: InnerType = undefined;
            inline for (types) |st| {
                @field(tmp, @typeName(st)) = try ally.alloc(st, count);
                @memset(@field(tmp, @typeName(st)), st.default);
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

        pub fn value(self: Self, comptime T: type) T {
            var sum: T = @as(T, 0);
            inline for (types) |st| {
                for (@field(self.inner, @typeName(st))) |s| {
                    sum += s.value();
                }
            }
            return sum;
        }
    };
}
