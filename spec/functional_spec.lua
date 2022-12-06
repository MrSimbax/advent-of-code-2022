local F = require "libs/functional"

describe("Functional programming module", function ()
    describe("has function id which", function ()
        it("returns its argument", function ()
            assert.are.equal(nil, F.id(nil))
            assert.are.equal(1, F.id(1))
            assert.are.equal(true, F.id(true))
            assert.are.equal("", F.id(""))
            local t = {}
            assert.are.equal(t, F.id(t))
        end)

        it("returns all its arguments", function ()
            local t = {}
            local a, b, c = F.id(1, "a", t)
            assert.are.equal(1, a)
            assert.are.equal("a", b)
            assert.are.equal(t, c)
        end)
    end)

    describe("has function copySeq which", function ()
        it("returns empty sequence when given an empty sequence", function ()
            local as = {}
            local bs = F.copySeq(as)
            assert.are.same({}, bs)
            assert.are_not.equal(as, bs)
        end)

        it("returns a copy of a sequence", function ()
            local as = {1, 2, 3}
            local bs = F.copySeq(as)
            assert.are.same(as, bs)
            assert.are_not.equal(as, bs)
        end)
    end)

    describe("has function reduceSeq which", function ()
        local function plus (a, b)
            return a + b
        end

        it("is left fold the sequence with operation starting from init", function ()
            assert.are.same(10, F.reduceSeq(plus, 0, {1, 2, 3, 4}))
        end)

        it("returns init for empty sequence", function ()
            assert.are.same(5, F.reduceSeq(plus, 5, {}))
        end)

        it("can handle singletons", function ()
            assert.are.same(2, F.reduceSeq(plus, 1, {1}))
        end)

        it("can handle operations which are not commutative", function ()
            assert.are.same("ab", F.reduceSeq(function (a, b) return a .. b end, "", {"a", "b"}))
        end)
    end)

    describe("has function reduce which", function ()
        local function plus (a, b)
            return a + b
        end

        it("has the same result as reduceSeq for sequences", function ()
            assert.are.same(F.reduceSeq(plus, 0, {1, 2, 3, 4}), F.reduce(plus, 0, {1, 2, 3, 4}))
        end)

        it("reduces values in tables for commutative operations", function ()
            assert.are.same(10, F.reduce(plus, 0, {a = 1, b = 2, c = 3, d = 4}))
        end)

        -- the test is not portable as the order of keys in tables is not specified, leaving as comment
        -- it("cannot handle operations which are not commutative", function ()
        --     assert.are_not.same("ab", F.reduce(function (a, b) return a .. b end, "", {a = "a", b = "b"}))
        -- end)
    end)

    describe("has function sum which", function ()
        it("sums given sequence", function ()
            assert.are.same(6, F.sum{1, 2, 3})
        end)

        it("sums empty sequence", function ()
            assert.are.same(0, F.sum{})
        end)
    end)

    describe("has function maximum which", function ()
        it("returns max value in sequence", function ()
            assert.are.same(3, F.maximum{1, 2, 3})
        end)
    end)

    describe("has function map which", function ()
        it("maps values in sequence using the given function", function ()
            assert.are.same({"1", "2", "3"}, F.map(tostring, {1, 2, 3}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.map(tostring, {}))
        end)
    end)

    describe("has function sorted which", function ()
        it("returns a sorted sequence", function ()
            assert.are.same({1, 2, 3}, F.sorted{3, 1, 2})
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.sorted{})
        end)

        it("uses the given comparison operation", function ()
            assert.are.same({3, 2, 1}, F.sorted({3, 1, 2}, function (a, b) return a > b end))
        end)
    end)

    describe("has function reversed which", function ()
        it("returns the sequence reversed", function ()
            assert.are.same({3, 2, 1}, F.reversed{1, 2, 3})
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.reversed{})
        end)
    end)

    describe("has function take which", function ()
        it("returns the first n elements from the sequence", function ()
            assert.are.same({1, 2}, F.take(2, {1, 2, 3}))
        end)

        it("returns none elements from the sequence when n = 0", function ()
            assert.are.same({}, F.take(0, {1, 2, 3}))
        end)

        it("returns all elements from the sequence when n is the length of the sequence", function ()
            assert.are.same({1, 2, 3}, F.take(3, {1, 2, 3}))
        end)

        it("returns all elements from the sequence when n is greater than the length of the sequence", function ()
            assert.are.same({1, 2, 3}, F.take(10, {1, 2, 3}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.take(0, {}))
            assert.are.same({}, F.take(10, {}))
        end)
    end)

    describe("has function skip which", function ()
        it("returns all but the first n elements from the sequence", function ()
            assert.are.same({3}, F.skip(2, {1, 2, 3}))
        end)

        it("returns all elements from the sequence when n = 0", function ()
            assert.are.same({1, 2, 3}, F.skip(0, {1, 2, 3}))
        end)

        it("returns none elements from the sequence when n is the length of the sequence", function ()
            assert.are.same({}, F.skip(3, {1, 2, 3}))
        end)

        it("returns none elements from the sequence when n is greater than the length of the sequence", function ()
            assert.are.same({}, F.skip(10, {1, 2, 3}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.skip(0, {}))
            assert.are.same({}, F.skip(10, {}))
        end)
    end)

    describe("has function head which", function ()
        it("returns the first element of the sequence", function ()
            assert.are.same(1, F.head{1, 2, 3})
        end)

        it("returns nothing for empty sequence", function ()
            assert.is.Nil(F.head{})
        end)
    end)

    describe("has function last which", function ()
        it("returns the last element of the sequence", function ()
            assert.are.same(3, F.last{1, 2, 3})
        end)

        it("returns nothing for empty sequence", function ()
            assert.is.Nil(F.last{})
        end)
    end)

    describe("has function inversed which", function ()
        it("returns a dual table", function ()
            assert.are.same({[1] = "a", [2] = "b", [3] = "c"}, F.inversed{a = 1, b = 2, c = 3})
        end)

        it("returns empty table for empty table", function ()
            assert.are.same({}, F.inversed{})
        end)
    end)

    describe("has function compose which", function ()
        local function mul2 (a)
            return a * 2
        end

        local function add3 (a)
            return a + 3
        end

        local function pow2 (a)
            return a^2
        end

        it("returns id when given no function", function ()
            assert.are.same(2, F.compose()(2))
        end)

        it("returns the function when given a function", function ()
            assert.are.same(5, F.compose(add3)(2))
        end)

        it("returns function g . f given two functions g and f", function ()
            assert.are.same(10, F.compose(mul2, add3)(2))
            assert.are.same(7, F.compose(add3, mul2)(2))
        end)

        it("returns function h . g . f given three functions h and g and f", function ()
            assert.are.same(100, F.compose(pow2, mul2, add3)(2))
            assert.are.same(19, F.compose(add3, pow2, mul2)(2))
            assert.are.same(11, F.compose(add3, mul2, pow2)(2))
        end)

        it("returns function g . f given two functions g and f of two or more variables", function ()
            local function f (a, b)
                return a + 3, b * 2
            end

            local function g (a, b)
                return a - 4, b % 2
            end

            local a, b = F.compose(g, f)(2, 3)
            assert.are.same(1, a)
            assert.are.same(0, b)
        end)
    end)

    describe("has function groupsOf which", function ()
        it("splits sequence into groups of 1", function ()
            assert.are.same({{1}, {2}, {3}}, F.groupsOf(1, {1, 2, 3}))
        end)

        it("splits sequence into groups of 2", function ()
            assert.are.same({{1, 2}, {3, 4}, {5, 6}}, F.groupsOf(2, {1, 2, 3, 4, 5, 6}))
        end)

        it("splits sequence into groups of 3, leaving the rest elements in the last group", function ()
            assert.are.same({{1, 2, 3}, {4, 5, 6}, {7, 8}}, F.groupsOf(3, {1, 2, 3, 4, 5, 6, 7, 8}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.groupsOf(3, {}))
        end)

        it("throws error when n = 0", function ()
            assert.has.error(function () F.groupsOf(0, {1, 2, 3}) end)
        end)
    end)

    describe("has function collect which", function ()
        it("converts numerical range to a sequence", function ()
            assert.are.same({2, 3, 4, 5, 6}, F.collect(2, 6))
        end)

        it("converts numerical range to a sequence with given step", function ()
            assert.are.same({2, 4, 6}, F.collect(2, 6, 2))
            assert.are.same({2, 4, 6}, F.collect(2, 7, 2))
        end)

        it("converts numerical range to a sequence with given negative step", function ()
            assert.are.same({6, 5, 4, 3, 2}, F.collect(6, 2, -1))
            assert.are.same({6, 4, 2}, F.collect(6, 2, -2))
            assert.are.same({7, 5, 3}, F.collect(7, 2, -2))
        end)

        it("converts numerical range to a sequence, and assumes negative step", function ()
            assert.are.same({6, 5, 4, 3, 2}, F.collect(6, 2))
        end)

        it("converts empty numerical range to empty sequence", function ()
            assert.are.same({}, F.collect(3, 1, 1))
            assert.are.same({}, F.collect(1, 3, -1))
        end)
    end)

    describe("has function filter which", function ()
        local function isEven (a)
            return a % 2 == 0
        end

        it("returns all elements of the sequence for which the predicate is true", function ()
            assert.are.same({2, 4}, F.filter(isEven, {1, 2, 3, 4, 5}))
        end)

        it("returns empty sequence when none of the elements satisfy the predicate", function ()
            assert.are.same({}, F.filter(isEven, {1, 3, 5}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.filter(isEven, {}))
        end)
    end)

    describe("has function takeWhile which", function ()
        local function isEven (a)
            return a % 2 == 0
        end

        it("returns the first elements of the sequence for which the predicate is true", function ()
            assert.are.same({2, 4}, F.takeWhile(isEven, {2, 4, 3, 6}))
        end)

        it("returns empty sequence when none of the first elements satisfy the predicate", function ()
            assert.are.same({}, F.takeWhile(isEven, {1, 2}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.takeWhile(isEven, {}))
        end)
    end)

    describe("has function skipWhile which", function ()
        local function isEven (a)
            return a % 2 == 0
        end

        it("returns all but the first elements of the sequence for which the predicate is true", function ()
            assert.are.same({3, 6}, F.skipWhile(isEven, {2, 4, 3, 6}))
        end)

        it("returns all elements when none of the first elements satisfy the predicate", function ()
            assert.are.same({1, 2}, F.skipWhile(isEven, {1, 2}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.skipWhile(isEven, {}))
        end)
    end)

    describe("has function split which", function ()
        it("returns sequence split by the given delimiter", function ()
            assert.are.same({{1, 2, 3}, {4, 5}, {6, 7, 8}}, F.split(0, {1, 2, 3, 0, 4, 5, 0, 6, 7, 8}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.split(0, {}))
        end)

        it("returns empty group if there are no elements after delimiter", function ()
            assert.are.same({{1}, {}}, F.split(0, {1, 0}))
        end)

        it("returns empty group if there are no elements before delimiter", function ()
            assert.are.same({{}, {1}}, F.split(0, {0, 1}))
        end)

        it("returns empty group if there are no elements between two delimiters", function ()
            assert.are.same({{1}, {}, {2}}, F.split(0, {1, 0, 0, 2}))
        end)
    end)

    describe("has function sequence which", function ()
        local function mul2 (i)
            return 2 * i
        end

        it("returns the first n elements of a sequence a(i)", function ()
            assert.are.same({2, 4, 6}, F.sequence(mul2, 3))
        end)

        it("returns empty sequence for n = 0", function ()
            assert.are.same({}, F.sequence(mul2, 0))
        end)
    end)

    describe("has function const which", function ()
        it("returns function which always returns the same object", function ()
            local t = {}
            local f = F.const(t)
            assert.are.equal(t, f {})
            assert.are.equal(t, f "potato")
            assert.are.equal(t, f(1))
            assert.are.equal(t, f(1, 2, 3))
        end)
    end)

    describe("has function slice which", function ()
        it("returns part of the sequence", function ()
            assert.are.same({"b", "c"}, F.slice(2, 3, {"a", "b", "c", "d", "e"}))
        end)

        it("returns a singleton", function ()
            assert.are.same({"c"}, F.slice(3, 3, {"a", "b", "c", "d", "e"}))
        end)

        it("returns empty sequence for invalid range", function ()
            assert.are.same({}, F.slice(4, 3, {"a", "b", "c", "d", "e"}))
        end)

        it("returns empty sequence for empty sequence", function ()
            assert.are.same({}, F.slice(2, 3, {}))
        end)
    end)
end)
