local F = require "libs.functional"

describe("functional module", function ()
    describe("has function lazy which", function ()
        it("produces a lazy sequence from sequence", function ()
            local a = F.lazy{1, 2, 3}
            assert.are.same(1, a(1))
            assert.are.same(2, a(2))
            assert.are.same(3, a(3))
        end)
    end)

    describe("has function id which", function ()
        it("returns the same sequence", function ()
            local a = F.id(F.lazy{1, 2, 3})
            assert.are.same(1, a(1))
            assert.are.same(2, a(2))
            assert.are.same(3, a(3))
        end)
    end)

    describe("has function reduce which", function ()
        it("reduces sequence to single value using left fold", function ()
            local x = F.reduce(F.mult, 1, F.lazy{1, 2, 4})
            assert.are.same(8, x)
        end)
    end)

    describe("has function sum which", function ()
        it("returns sum", function ()
            local x = F.sum(F.lazy{1, 2, 3})
            assert.are.same(6, x)
        end)
    end)

    describe("has function maximum which", function ()
        it("returns maximum", function ()
            local x = F.maximum(F.lazy{1, 2, 3})
            assert.are.same(3, x)
        end)
    end)

    describe("has function minimum which", function ()
        it("returns minimum", function ()
            local x = F.minimum(F.lazy{1, 2, 3})
            assert.are.same(1, x)
        end)
    end)

    describe("has function map which", function ()
        it("maps over sequence", function ()
            local a = F.map(tostring, F.lazy{1, 2, 3})
            assert.are.same("1", a(1))
            assert.are.same("2", a(2))
            assert.are.same("3", a(3))
        end)
    end)

    describe("has function length which", function ()
        it("returns length of sequence", function ()
            local x = F.length(F.lazy{"1", "2", "3"})
            assert.are.same(3, x)
        end)
    end)

    describe("has function reverse which", function ()
        it("returns reversed sequence", function ()
            local as = F.reverse(F.lazy{1, 2, 3})
            assert.are.same(3, as(1))
            assert.are.same(2, as(2))
            assert.are.same(1, as(3))
        end)
    end)

    describe("has function take which", function ()
        it("returns first n elements of sequence", function ()
            local as = F.take(2, F.lazy{1, 2, 3})
            assert.are.same(1, as(1))
            assert.are.same(2, as(2))
            assert.is.Nil(as(3))
        end)
    end)

    describe("has function skip which", function ()
        it("returns all but first n elements of sequence", function ()
            local as = F.skip(2, F.lazy{1, 2, 3})
            assert.are.same(3, as(1))
        end)
    end)

    describe("has function head which", function ()
        it("returns the first element", function ()
            local x = F.head(F.lazy{1, 2, 3})
            assert.are.same(1, x)
        end)
    end)

    describe("has function tail which", function ()
        it("returns all but the first element", function ()
            local as = F.tail(F.lazy{1, 2, 3})
            assert.are.same(2, as(1))
            assert.are.same(3, as(2))
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

    describe("has function collect which", function ()
        it("returns a table from sequence", function ()
            local as = F.collect(F.lazy{1, 2, 3})
            assert.are.same({1, 2, 3}, as)
        end)
    end)

    describe("allows function composition of", function ()
        it("map reduce", function ()
            local x = F.reduce(F.plus, 0, F.map(tonumber, F.lazy{"1", "2", "3"}))
            assert.are.same(6, x)
        end)

        it("map of composed functions", function ()
            local as = F.map(F.compose(tostring, tonumber), F.lazy{"1", "2", "3"})
            assert.are.same("1", as(1))
            assert.are.same("2", as(2))
            assert.are.same("3", as(3))
        end)
    end)

    describe("has function same which", function ()
        it("returns true for two empty sequences", function ()
            assert.is.True(F.same(F.eq, F.lazy{}, F.lazy{}))
        end)

        it("returns true if two sequences are the same", function ()
            assert.is.True(F.same(F.eq, F.lazy{1, 2, 3}, F.lazy{1, 2, 3}))
        end)

        it("returns false for sequences of different lengths", function ()
            assert.is.False(F.same(F.eq, F.lazy{1, 2}, F.lazy{1, 2, 3}))
        end)

        it("uses the provided eq operation", function ()
            assert.is.True(F.same(function () return true end, F.lazy{1}, F.lazy{2}))
        end)
    end)

    local function assertSameSequences (as, bs)
        assert.is.True(F.same(F.eq, as, bs))
    end

    describe("has function groupsOf which", function ()
        it("splits sequence into groups of 1", function ()
            local as = F.groupsOf(1, F.lazy{1, 2, 3})
            assertSameSequences(F.lazy{1}, as(1))
            assertSameSequences(F.lazy{2}, as(2))
            assertSameSequences(F.lazy{3}, as(3))
        end)

        it("splits sequence into groups of 2", function ()
            local as = F.groupsOf(2, F.lazy{1, 2, 3, 4, 5, 6})
            assertSameSequences(F.lazy{1, 2}, as(1))
            assertSameSequences(F.lazy{3, 4}, as(2))
            assertSameSequences(F.lazy{5, 6}, as(3))
        end)

        it("splits sequence into groups of 3, leaving the rest elements in the last group", function ()
            local as = F.groupsOf(3, F.lazy{1, 2, 3, 4, 5, 6, 7, 8})
            assertSameSequences(F.lazy{1, 2, 3}, as(1))
            assertSameSequences(F.lazy{4, 5, 6}, as(2))
            assertSameSequences(F.lazy{7, 8}, as(3))
        end)
    end)
end)
