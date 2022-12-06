local Set = require "libs/Set"

describe("Set", function ()
    describe(".new", function ()
        it("creates empty set from empty list", function ()
            assert.are.same({}, Set.new{})
        end)

        it("creates a set from non-empty list", function ()
            assert.are.same(Set.new{1, "a", "b"}, Set.new{1, 1, 1, "a", "b", "a"})
        end)
    end)

    describe("contains", function ()
        it("no elements when set is empty", function ()
            local set = Set.new{}
            assert.is.falsy(set[1])
            assert.is.falsy(set["a"])
            assert.is.falsy(set[{}])
            assert.is.falsy(set[true])
        end)

        it("only elements which are in the set", function ()
            local set = Set.new{1, 2}
            assert.is.truthy(set[1])
            assert.is.truthy(set[2])
            assert.is.falsy(set[3])
            assert.is.falsy(set["a"])
            assert.is.falsy(set[{}])
            assert.is.falsy(set[true])
        end)
    end)

    describe(".add", function ()
        it("adds new element to a set", function ()
            local set = Set.new{1}
            Set.add(set, 2)
            assert.are.same(Set.new{1, 2}, set)
        end)

        it("adds new element to empty set", function ()
            local set = Set.new{}
            Set.add(set, 2)
            assert.are.same(Set.new{2}, set)
        end)

        it("of an element already in a set does not change the set", function ()
            local set = Set.new{1}
            Set.add(set, 1)
            assert.are.same(Set.new{1}, set)
        end)
    end)

    describe(".del", function ()
        it("removes an element from a set", function ()
            local set = Set.new{1, 2}
            Set.del(set, 1)
            assert.are.same(Set.new{2}, set)
        end)

        it("does not change an empty set", function ()
            local set = Set.new{}
            Set.del(set, 2)
            assert.are.same(Set.new{}, set)
        end)

        it("of an element not in a set does not change the set", function ()
            local set = Set.new{1}
            Set.del(set, 2)
            assert.are.same(Set.new{1}, set)
        end)
    end)

    describe(".union", function ()
        it("is + operator", function ()
            assert.are.same(Set.union, getmetatable(Set.new{}).__add)
        end)

        it("with empty set is identity", function ()
            assert.are.same(Set.new{}, Set.new{} + Set.new{})
            assert.are.same(Set.new{1}, Set.new{} + Set.new{1})
            assert.are.same(Set.new{1}, Set.new{1} + Set.new{})
        end)

        it("is union of sets", function ()
            assert.are.same(Set.new{1, 2, 3}, Set.new{1, 2} + Set.new{2, 3})
        end)

        it("does not modify given sets", function ()
            local a = Set.new{1}
            local b = Set.new{2}
            assert.is.truthy(a + b)
            assert.are.same(Set.new{1}, a)
            assert.are.same(Set.new{2}, b)
        end)

        it("throws error for non-sets", function ()
            assert.has_error(function () return Set.new{} + {} end)
            assert.has_error(function () return {} + Set.new{} end)
            assert.has_error(function () return 1 + Set.new{} end)
            assert.has_error(function () return Set.new{} + 1 end)
        end)
    end)

    describe(".intersection", function ()
        it("is * operator", function ()
            assert.are.same(Set.intersection, getmetatable(Set.new{}).__mul)
        end)

        it("with empty set is empty set", function ()
            assert.are.same(Set.new{}, Set.new{} * Set.new{})
            assert.are.same(Set.new{}, Set.new{} * Set.new{1})
            assert.are.same(Set.new{}, Set.new{1} * Set.new{})
        end)

        it("is intersection of sets", function ()
            assert.are.same(Set.new{2}, Set.new{1, 2} * Set.new{2, 3})
        end)

        it("does not modify given sets", function ()
            local a = Set.new{1}
            local b = Set.new{2}
            assert.is.truthy(a * b)
            assert.are.same(Set.new{1}, a)
            assert.are.same(Set.new{2}, b)
        end)

        it("throws error for non-sets", function ()
            assert.has_error(function () return Set.new{} * {} end)
            assert.has_error(function () return {} * Set.new{} end)
            assert.has_error(function () return 1 * Set.new{} end)
            assert.has_error(function () return Set.new{} * 1 end)
        end)
    end)

    describe(".difference", function ()
        it("is - operator", function ()
            assert.are.same(Set.difference, getmetatable(Set.new{}).__sub)
        end)

        it("with empty set is identity", function ()
            assert.are.same(Set.new{}, Set.new{} - Set.new{})
            assert.are.same(Set.new{1}, Set.new{1} - Set.new{})
        end)

        it("of empty set is empty", function ()
            assert.are.same(Set.new{}, Set.new{} - Set.new{1})
        end)

        it("is difference of sets", function ()
            assert.are.same(Set.new{1}, Set.new{1, 2} - Set.new{2, 3})
        end)

        it("does not modify given sets", function ()
            local a = Set.new{1}
            local b = Set.new{2}
            assert.is.truthy(a - b)
            assert.are.same(Set.new{1}, a)
            assert.are.same(Set.new{2}, b)
        end)

        it("throws error for non-sets", function ()
            assert.has_error(function () return Set.new{} - {} end)
            assert.has_error(function () return {} - Set.new{} end)
            assert.has_error(function () return 1 - Set.new{} end)
            assert.has_error(function () return Set.new{} - 1 end)
        end)
    end)

    describe(".size", function ()
        it("is # operator", function ()
            assert.are.same(Set.size, getmetatable(Set.new{}).__len)
        end)

        it("of empty set is 0", function ()
            assert.are.same(0, #Set.new{})
        end)

        it("of singleton is 1", function ()
            assert.are.same(1, #Set.new{10})
        end)

        it("of a set of non-unique values is the amount of unique values", function ()
            assert.are.same(3, #Set.new{1, 1, 1, 2, 2, 3})
        end)

        it("of union is correct", function ()
            assert.are.same(3, #(Set.new{1, 2} + Set.new{2, 3}))
        end)

        it("of intersection is correct", function ()
            assert.are.same(1, #(Set.new{1, 2} * Set.new{2, 3}))
        end)

        it("of difference is correct", function ()
            assert.are.same(1, #(Set.new{1, 2} - Set.new{2, 3}))
        end)

        it("of modified set is correct", function ()
            local set = Set.new{1, 2, 3}
            assert.are.same(3, #set)

            Set.add(set, 10)
            assert.are.same(4, #set)

            Set.add(set, 10)
            assert.are.same(4, #set)

            Set.del(set, 10)
            assert.are.same(3, #set)

            Set.del(set, 10)
            assert.are.same(3, #set)
        end)
    end)

    describe(".isSubset", function ()
        it("is <= operator", function ()
            assert.are.same(Set.isSubset, getmetatable(Set.new{}).__le)
        end)

        it("is true when a set is a strict subset of the other set", function ()
            assert.is.True(Set.new{2, 3} <= Set.new{1, 2, 3})
        end)

        it("is true when a set is compared with itself", function ()
            local a = Set.new{1, 2, 3}
            assert.is.True(a <= a)
            assert.is.True(a <= Set.new{1, 2, 3})
        end)

        it("is false when a set is a strict superset of the other set", function ()
            assert.is.False(Set.new{1, 2, 3} <= Set.new{1, 2})
        end)

        it("is true when empty set is compared with any other set", function ()
            assert.is.True(Set.new{} <= Set.new{})
            assert.is.True(Set.new{} <= Set.new{1})
            assert.is.True(Set.new{} <= Set.new{1, 2, 3})
        end)

        it("is false when any non-empty set is compared with empty set", function ()
            assert.is.False(Set.new{1} <= Set.new{})
            assert.is.False(Set.new{1, 2, 3} <= Set.new{})
        end)
    end)

    describe(".isStrictSubset", function ()
        it("is < operator", function ()
            assert.are.same(Set.isStrictSubset, getmetatable(Set.new{}).__lt)
        end)

        it("is true when a set is a strict subset of the other set", function ()
            assert.is.True(Set.new{2, 3} < Set.new{1, 2, 3})
        end)

        it("is false when a set is compared with itself", function ()
            local a = Set.new{1, 2, 3}
            assert.is.False(a < a)
            assert.is.False(a < Set.new{1, 2, 3})
        end)

        it("is false when a set is a strict superset of the other set", function ()
            assert.is.False(Set.new{1, 2, 3} < Set.new{1, 2})
        end)

        it("is true when empty set is compared with any non-empty set", function ()
            assert.is.True(Set.new{} < Set.new{1})
            assert.is.True(Set.new{} < Set.new{1, 2, 3})
        end)

        it("is false when any non-empty set is compared with empty set", function ()
            assert.is.False(Set.new{} < Set.new{})
            assert.is.False(Set.new{1} < Set.new{})
            assert.is.False(Set.new{1, 2, 3} < Set.new{})
        end)
    end)

    describe(".areEqual", function ()
        it("is == operator", function ()
            assert.are.same(Set.areEqual, getmetatable(Set.new{}).__eq)
        end)

        it("is true when sets are the same", function ()
            assert.is.True(Set.new{2, 3} == Set.new{2, 3})
        end)

        it("is false when sets are different", function ()
            assert.is.False(Set.new{2, 3} == Set.new{2})
        end)

        it("is true when comparing empty sets", function ()
            assert.is.True(Set.new{} == Set.new{})
        end)

        it("is false when comparing an empty set with a non-empty set", function ()
            assert.is.False(Set.new{1, 2, 3} == Set.new{})
            assert.is.False(Set.new{} == Set.new{1, 2, 3})
        end)
    end)

    describe(".toSeq", function ()
        it("returns empty sequence when given empty set", function ()
            assert.are.same({}, Set.toSeq(Set.new{}))
        end)

        it("returns a sequence of elements from a non-empty set", function ()
            local seq = Set.toSeq(Set.new{1, 2, 3})
            -- no unordered check in luassert :(
            assert.are.same(3, #seq)
            assert.are.unique(seq)
            assert.is.True(seq[1] == 1 or seq[1] == 2 or seq[1] == 3)
            assert.is.True(seq[2] == 1 or seq[2] == 2 or seq[2] == 3)
            assert.is.True(seq[3] == 1 or seq[3] == 2 or seq[3] == 3)
        end)
    end)

    describe(".toString", function ()
        it("returns \"{}\" from empty set", function ()
            assert.are.same("{}", Set.toString(Set.new{}))
        end)

        it("returns \"{a}\" from singleton {a}", function ()
            assert.are.same("{1}", Set.toString(Set.new{1}))
        end)

        it("returns \"{a, b}\" or \"{b, a}\" from set {a, b}", function ()
            local str = Set.toString(Set.new{1, 2})
            assert.is.True("{1, 2}" == str or "{2, 1}" == str)
        end)
    end)
end)
