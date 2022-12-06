local MultiSet = require "libs/MultiSet"

describe("MultiSet", function ()
    describe(".new", function ()
        it("creates empty multiset from empty sequence", function ()
            assert.are.same({}, MultiSet.new{})
        end)

        it("creates a multiset from non-empty sequence", function ()
            assert.are.same(MultiSet.new{1, "b", 1, "a", 1, "a"}, MultiSet.new{1, 1, 1, "a", "b", "a"})
            assert.are_not.same(MultiSet.new{1, "a", "b"}, MultiSet.new{1, 1, 1, "a", "b", "a"})
        end)
    end)

    describe("contains", function ()
        it("no elements when multiset is empty", function ()
            local mset = MultiSet.new{}
            assert.is.falsy(mset[1])
            assert.is.falsy(mset["a"])
            assert.is.falsy(mset[{}])
            assert.is.falsy(mset[true])
        end)

        it("only elements which are in the multiset", function ()
            local mset = MultiSet.new{1, 3, 3}
            assert.are.same(1, mset[1])
            assert.are.same(2, mset[3])
            assert.is.falsy(mset[2])
            assert.is.falsy(mset["a"])
            assert.is.falsy(mset[{}])
            assert.is.falsy(mset[true])
        end)
    end)

    describe(".add", function ()
        it("adds new element to a multiset", function ()
            local mset = MultiSet.new{1}
            MultiSet.add(mset, 2)
            assert.are.same(MultiSet.new{1, 2}, mset)
        end)

        it("adds multiple new elements to a multiset", function ()
            local mset = MultiSet.new{1}
            MultiSet.add(mset, 2, 5)
            assert.are.same(MultiSet.new{1, 2, 2, 2, 2, 2}, mset)
        end)

        it("adds new element to empty multiset", function ()
            local mset = MultiSet.new{}
            MultiSet.add(mset, 2)
            assert.are.same(MultiSet.new{2}, mset)
        end)

        it("adds multiple new elements to empty multiset", function ()
            local mset = MultiSet.new{}
            MultiSet.add(mset, 2, 5)
            assert.are.same(MultiSet.new{2, 2, 2, 2, 2}, mset)
        end)

        it("adds existing element to a multiset", function ()
            local mset = MultiSet.new{1}
            MultiSet.add(mset, 1)
            assert.are.same(MultiSet.new{1, 1}, mset)
        end)

        it("adds multiple existing elements to a multiset", function ()
            local mset = MultiSet.new{1}
            MultiSet.add(mset, 1, 5)
            assert.are.same(MultiSet.new{1, 1, 1, 1, 1, 1}, mset)
        end)
    end)

    describe(".del", function ()
        it("removes an element completely from a multiset", function ()
            local mset = MultiSet.new{1, 2}
            MultiSet.del(mset, 1)
            assert.are.same(MultiSet.new{2}, mset)
        end)

        it("removes multiple elements completely from a multiset", function ()
            local mset = MultiSet.new{1, 1, 1, 2}
            MultiSet.del(mset, 1, 3)
            assert.are.same(MultiSet.new{2}, mset)
        end)

        it("removes an element from a multiset", function ()
            local mset = MultiSet.new{1, 1, 2}
            MultiSet.del(mset, 1)
            assert.are.same(MultiSet.new{1, 2}, mset)
        end)

        it("removes multiple elements from a multiset", function ()
            local mset = MultiSet.new{1, 1, 1, 3}
            MultiSet.del(mset, 1, 2)
            assert.are.same(MultiSet.new{1, 3}, mset)
        end)

        it("does not change an empty multiset", function ()
            local mset = MultiSet.new{}
            MultiSet.del(mset, 2)
            assert.are.same(MultiSet.new{}, mset)
            MultiSet.del(mset, 2, 10)
            assert.are.same(MultiSet.new{}, mset)
        end)

        it("of an element not in a multiset does not change the multiset", function ()
            local mset = MultiSet.new{1, 1}
            MultiSet.del(mset, 2)
            assert.are.same(MultiSet.new{1, 1}, mset)
            MultiSet.del(mset, 2, 10)
            assert.are.same(MultiSet.new{1, 1}, mset)
        end)
    end)

    describe(".union", function ()
        it("is + operator", function ()
            assert.are.same(MultiSet.union, getmetatable(MultiSet.new{}).__add)
        end)

        it("with empty multiset is identity", function ()
            assert.are.same(MultiSet.new{}, MultiSet.new{} + MultiSet.new{})
            assert.are.same(MultiSet.new{1, 1}, MultiSet.new{} + MultiSet.new{1, 1})
            assert.are.same(MultiSet.new{1, 1}, MultiSet.new{1, 1} + MultiSet.new{})
        end)

        it("is union of multisets", function ()
            assert.are.same(MultiSet.new{1, 1, 2, 2, 3, 3}, MultiSet.new{1, 1, 2} + MultiSet.new{2, 3, 3})
        end)

        it("does not modify given multisets", function ()
            local a = MultiSet.new{1, 1}
            local b = MultiSet.new{2, 2}
            assert.is.truthy(a + b)
            assert.are.same(MultiSet.new{1, 1}, a)
            assert.are.same(MultiSet.new{2, 2}, b)
        end)

        it("throws error for non-multisets", function ()
            assert.has_error(function () return MultiSet.new{} + {} end)
            assert.has_error(function () return {} + MultiSet.new{} end)
            assert.has_error(function () return 1 + MultiSet.new{} end)
            assert.has_error(function () return MultiSet.new{} + 1 end)
        end)
    end)

    describe(".intersection", function ()
        it("is * operator", function ()
            assert.are.same(MultiSet.intersection, getmetatable(MultiSet.new{}).__mul)
        end)

        it("with empty multiset is empty multiset", function ()
            assert.are.same(MultiSet.new{}, MultiSet.new{} * MultiSet.new{})
            assert.are.same(MultiSet.new{}, MultiSet.new{} * MultiSet.new{1, 1})
            assert.are.same(MultiSet.new{}, MultiSet.new{1, 1} * MultiSet.new{})
        end)

        it("is intersection of multisets", function ()
            assert.are.same(MultiSet.new{2}, MultiSet.new{1, 1, 2} * MultiSet.new{2, 3, 3})
        end)

        it("does not modify given multisets", function ()
            local a = MultiSet.new{1, 1}
            local b = MultiSet.new{2, 2}
            assert.is.truthy(a * b)
            assert.are.same(MultiSet.new{1, 1}, a)
            assert.are.same(MultiSet.new{2, 2}, b)
        end)

        it("throws error for non-multisets", function ()
            assert.has_error(function () return MultiSet.new{} * {} end)
            assert.has_error(function () return {} * MultiSet.new{} end)
            assert.has_error(function () return 1 * MultiSet.new{} end)
            assert.has_error(function () return MultiSet.new{} * 1 end)
        end)
    end)

    describe(".difference", function ()
        it("is - operator", function ()
            assert.are.same(MultiSet.difference, getmetatable(MultiSet.new{}).__sub)
        end)

        it("with empty multiset is identity", function ()
            assert.are.same(MultiSet.new{}, MultiSet.new{} - MultiSet.new{})
            assert.are.same(MultiSet.new{1}, MultiSet.new{1} - MultiSet.new{})
            assert.are.same(MultiSet.new{1, 1}, MultiSet.new{1, 1} - MultiSet.new{})
        end)

        it("of empty multiset is empty", function ()
            assert.are.same(MultiSet.new{}, MultiSet.new{} - MultiSet.new{1, 1})
        end)

        it("is difference of multisets", function ()
            assert.are.same(MultiSet.new{2}, MultiSet.new{1, 1, 2, 2} - MultiSet.new{1, 1, 2, 3, 3})
        end)

        it("does not modify given multisets", function ()
            local a = MultiSet.new{1, 1}
            local b = MultiSet.new{2, 2}
            assert.is.truthy(a - b)
            assert.are.same(MultiSet.new{1, 1}, a)
            assert.are.same(MultiSet.new{2, 2}, b)
        end)

        it("throws error for non-multisets", function ()
            assert.has_error(function () return MultiSet.new{} - {} end)
            assert.has_error(function () return {} - MultiSet.new{} end)
            assert.has_error(function () return 1 - MultiSet.new{} end)
            assert.has_error(function () return MultiSet.new{} - 1 end)
        end)
    end)

    describe(".size", function ()
        it("is # operator", function ()
            assert.are.same(MultiSet.size, getmetatable(MultiSet.new{}).__len)
        end)

        it("of empty multiset is 0", function ()
            assert.are.same(0, #MultiSet.new{})
        end)

        it("of singleton is 1", function ()
            assert.are.same(1, #MultiSet.new{10})
        end)

        it("of a multiset of non-unique values is the amount of values", function ()
            assert.are.same(6, #MultiSet.new{1, 1, 1, 2, 2, 3})
        end)

        it("of union is correct", function ()
            assert.are.same(6, #(MultiSet.new{1, 1, 2} + MultiSet.new{2, 3, 3}))
        end)

        it("of intersection is correct", function ()
            assert.are.same(1, #(MultiSet.new{1, 1, 2} * MultiSet.new{2, 3, 3}))
        end)

        it("of difference is correct", function ()
            assert.are.same(1, #(MultiSet.new{1, 1, 2} - MultiSet.new{1, 2, 3, 3}))
        end)

        it("of modified multiset is correct", function ()
            local set = MultiSet.new{1, 1, 2, 2}
            assert.are.same(4, #set)

            MultiSet.add(set, 10)
            assert.are.same(5, #set)

            MultiSet.add(set, 10, 4)
            assert.are.same(9, #set)

            MultiSet.add(set, 10)
            assert.are.same(10, #set)

            MultiSet.del(set, 10)
            assert.are.same(9, #set)

            MultiSet.del(set, 10, 4)
            assert.are.same(5, #set)

            MultiSet.del(set, 10)
            assert.are.same(4, #set)
        end)
    end)

    describe(".isSubset", function ()
        it("is <= operator", function ()
            assert.are.same(MultiSet.isSubset, getmetatable(MultiSet.new{}).__le)
        end)

        it("is true when a multiset is a strict subset of the other multiset", function ()
            assert.is.True(MultiSet.new{2, 3, 3} <= MultiSet.new{1, 2, 2, 3, 3})
        end)

        it("is true when a multiset is compared with itself", function ()
            local a = MultiSet.new{1, 2, 2}
            assert.is.True(a <= a)
            assert.is.True(a <= MultiSet.new{1, 2, 2})
        end)

        it("is false when a multiset is a strict superset of the other multiset", function ()
            assert.is.False(MultiSet.new{1, 2, 3, 4} <= MultiSet.new{1, 2, 3})
            assert.is.False(MultiSet.new{1, 2, 2, 3} <= MultiSet.new{1, 2, 3})
        end)

        it("is true when empty multiset is compared with any other multiset", function ()
            assert.is.True(MultiSet.new{} <= MultiSet.new{})
            assert.is.True(MultiSet.new{} <= MultiSet.new{1})
            assert.is.True(MultiSet.new{} <= MultiSet.new{1, 2, 2, 3})
        end)

        it("is false when any non-empty multiset is compared with empty multiset", function ()
            assert.is.False(MultiSet.new{1} <= MultiSet.new{})
            assert.is.False(MultiSet.new{1, 2, 2, 3} <= MultiSet.new{})
        end)
    end)

    describe(".isStrictSubset", function ()
        it("is < operator", function ()
            assert.are.same(MultiSet.isStrictSubset, getmetatable(MultiSet.new{}).__lt)
        end)

        it("is true when a multiset is a strict subset of the other multiset", function ()
            assert.is.True(MultiSet.new{2, 3, 3} < MultiSet.new{1, 2, 2, 3, 3})
        end)

        it("is false when a multiset is compared with itself", function ()
            local a = MultiSet.new{1, 2, 2}
            assert.is.False(a < a)
            assert.is.False(a < MultiSet.new{1, 2, 2})
        end)

        it("is false when a multiset is a strict superset of the other multiset", function ()
            assert.is.False(MultiSet.new{1, 2, 3, 4} < MultiSet.new{1, 2, 3})
            assert.is.False(MultiSet.new{1, 2, 2, 3} < MultiSet.new{1, 2, 3})
        end)

        it("is true when empty multiset is compared with any non-empty multiset", function ()
            assert.is.True(MultiSet.new{} < MultiSet.new{1})
            assert.is.True(MultiSet.new{} < MultiSet.new{1, 2, 2, 3})
        end)

        it("is false when any non-empty multiset is compared with empty multiset", function ()
            assert.is.False(MultiSet.new{} < MultiSet.new{})
            assert.is.False(MultiSet.new{1} < MultiSet.new{})
            assert.is.False(MultiSet.new{1, 2, 2, 3} < MultiSet.new{})
        end)
    end)

    describe(".areEqual", function ()
        it("is == operator", function ()
            assert.are.same(MultiSet.areEqual, getmetatable(MultiSet.new{}).__eq)
        end)

        it("is true when multisets are the same", function ()
            assert.is.True(MultiSet.new{2, 2, 3} == MultiSet.new{2, 2, 3})
        end)

        it("is false when multisets are different", function ()
            assert.is.False(MultiSet.new{2, 2, 3} == MultiSet.new{2, 3})
        end)

        it("is true when comparing empty multisets", function ()
            assert.is.True(MultiSet.new{} == MultiSet.new{})
        end)

        it("is false when comparing an empty multiset with a non-empty multiset", function ()
            assert.is.False(MultiSet.new{1, 2, 2, 3} == MultiSet.new{})
            assert.is.False(MultiSet.new{} == MultiSet.new{1, 2, 2, 3})
        end)
    end)

    describe(".toSeq", function ()
        it("returns empty sequence when given empty multiset", function ()
            assert.are.same({}, MultiSet.toSeq(MultiSet.new{}))
        end)

        it("returns a sequence of elements from a non-empty multiset", function ()
            local seq = MultiSet.toSeq(MultiSet.new{1, 2, 2})
            -- no unordered check in luassert :(
            assert.are.same(3, #seq)
            assert.is.True(
                (seq[1] == 1 and seq[2] == 2 and seq[3] == 2) or
                (seq[2] == 1 and seq[1] == 2 and seq[3] == 2) or
                (seq[3] == 1 and seq[1] == 2 and seq[2] == 2))
        end)
    end)

    describe(".toString", function ()
        it("returns \"{}\" from empty multiset", function ()
            assert.are.same("{}", MultiSet.toString(MultiSet.new{}))
        end)

        it("returns \"{a}\" from singleton {a}", function ()
            assert.are.same("{1}", MultiSet.toString(MultiSet.new{1}))
        end)

        it("returns \"{a, b, b}\" or \"{b, a, b}\" or \"{b, b, a}\" from multiset {a, b, b}", function ()
            local str = MultiSet.toString(MultiSet.new{1, 2, 2})
            assert.is.True("{1, 2, 2}" == str or "{2, 1, 2}" == str or "{2, 2, 1}" == str)
        end)
    end)
end)
