local Vec = require "libs.Vector"

describe("Vector", function ()
    describe(".new", function ()
        it("creates a new vector", function ()
            assert.are.same({1, 2, 3}, Vec.new{1, 2, 3})
        end)
    end)

    it("can be created by call", function ()
        assert.are.same({1, 2, 3}, Vec{1, 2, 3})
    end)

    describe("+", function ()
        it("adds components of two vectors", function ()
            assert.are.same({3, 3}, Vec{1, 2} + Vec{2, 1})
        end)

        it("adds left scalar to components", function ()
            assert.are.same({3, 2}, 1 + Vec{2, 1})
        end)

        it("adds right scalar to vector", function ()
            assert.are.same({3, 2}, Vec{2, 1} + 1)
        end)
    end)

    describe("*", function ()
        it("multiplies components of two vectors", function ()
            assert.are.same({5, 6}, Vec{10, 2} * Vec{0.5, 3})
        end)

        it("multiplies components by right scalar", function ()
            assert.are.same({5, 1}, Vec{10, 2} * 0.5)
        end)

        it("multiplies components by left scalar", function ()
            assert.are.same({5, 1}, 0.5 * Vec{10, 2})
        end)
    end)

    describe("-", function ()
        it("subtracts components of two vectors", function ()
            assert.are.same({2, -2}, Vec{4, 1} - Vec{2, 3})
        end)

        it("subtracts right scalar from components", function ()
            assert.are.same({1, -2}, Vec{4, 1} - 3)
        end)

        it("throws error when subtracting vector from scalar", function ()
            assert.has.error(function () return 2 - Vec{4, 1} end)
        end)
    end)

    describe("unary -", function ()
        it("applies unary - to all components", function ()
            assert.are.same({-2, 2}, -Vec{2, -2})
        end)
    end)

    describe("/", function ()
        it("divides components of two vectors", function ()
            assert.are.same({4, 8}, Vec{8, 4} / Vec{2, 0.5})
        end)

        it("divides components by the right scalar", function ()
            assert.are.same({4, 2}, Vec{8, 4} / 2)
        end)

        it("throws error when dividing scalar by vector", function ()
            assert.has.error(function () return 2 / Vec{1} end)
        end)
    end)

    -- describe("//", function ()
    --     it("divides components of two vectors", function ()
    --         assert.are.same({4, 1}, Vec{8, 5} // Vec{2, 3})
    --     end)

    --     it("divides components by the right scalar", function ()
    --         assert.are.same({3, 1}, Vec{9, 5} // 3)
    --     end)

    --     it("throws error when dividing scalar by vector", function ()
    --         assert.has.error(function () return 3 // Vec{1} end)
    --     end)
    -- end)

    describe("%", function ()
        it("takes modulo components of two vectors", function ()
            assert.are.same({0, 2}, Vec{8, 5} % Vec{2, 3})
        end)

        it("takes components modulo the right scalar", function ()
            assert.are.same({0, 2}, Vec{9, 5} % 3)
        end)

        it("throws error when taking scalar modulo vector", function ()
            assert.has.error(function () return 3 % Vec{1} end)
        end)
    end)

    describe("==", function ()
        it("returns true when vectors have the same components", function ()
            assert.is.True(Vec{4, 5} == Vec{4, 5})
        end)

        it("returns false when vectors have at least one different component", function ()
            assert.is.False(Vec{4, 2, 5} == Vec{4, 1, 5})
        end)

        it("returns true for two empty vectors", function ()
            assert.is.True(Vec{} == Vec{})
        end)

        it("does not allow comparison with non-vectors", function ()
            assert.has.error(function () return Vec{} == {} end)
            assert.has.error(function () return {} == Vec{} end)
        end)
    end)

    describe("<", function ()
        it("compares two vectors lexicographically", function ()
            assert.is.True(Vec{1, 2} < Vec{1, 3})
            assert.is.False(Vec{1, 3} < Vec{1, 2})
            assert.is.True(Vec{1, 2} < Vec{2, 1})
        end)

        it("is false when vectors are equal", function ()
            assert.is.False(Vec{1, 2} < Vec{1, 2})
        end)

        it("does not allow comparison with non-vectors", function ()
            assert.has.error(function () return Vec{} < {} end)
            assert.has.error(function () return {} < Vec{} end)
        end)
    end)

    describe("<=", function ()
        it("compares two vectors lexicographically", function ()
            assert.is.True(Vec{1, 2} <= Vec{1, 3})
            assert.is.False(Vec{1, 3} <= Vec{1, 2})
            assert.is.True(Vec{1, 2} <= Vec{2, 1})
        end)

        it("is true when vectors are equal", function ()
            assert.is.True(Vec{1, 2} <= Vec{1, 2})
        end)

        it("does not allow comparison with non-vectors", function ()
            assert.has.error(function () return Vec{} < {} end)
            assert.has.error(function () return {} < Vec{} end)
        end)
    end)

    it("allows composing operators", function()
        assert.are.same(Vec{1}, ((((Vec{1} + Vec{1}) * Vec{3}) / Vec{2}) / Vec{2}) % Vec{2})
    end)

    describe("allows swizzling", function ()
        local v = Vec.new{10, 20, 30, 40}

        it("to get single values", function ()
            assert.are.same(10, v.x)
            assert.are.same(20, v.y)
            assert.are.same(30, v.z)
            assert.are.same(40, v.w)

            assert.are.same(10, v.r)
            assert.are.same(20, v.g)
            assert.are.same(30, v.b)
            assert.are.same(40, v.a)

            assert.are.same(10, v.i)
            assert.are.same(20, v.j)
            assert.are.same(30, v.k)
            assert.are.same(40, v.l)
        end)

        it("to get multiple values", function ()
            assert.are.same(Vec{10, 20}, v.xy)
            assert.are.same(Vec{10, 20, 30}, v.xyz)
            assert.are.same(Vec{10, 20, 30, 40}, v.xyzw)

            assert.are.same(Vec{10, 20}, v.rg)
            assert.are.same(Vec{10, 20, 30}, v.rgb)
            assert.are.same(Vec{10, 20, 30, 40}, v.rgba)

            assert.are.same(Vec{10, 20}, v.ij)
            assert.are.same(Vec{10, 20, 30}, v.ijk)
            assert.are.same(Vec{10, 20, 30, 40}, v.ijkl)
        end)

        it("to get multiple values swapped", function ()
            assert.are.same(Vec{20, 10}, v.yx)
            assert.are.same(Vec{40, 20, 10, 30}, v.wyxz)

            assert.are.same(Vec{20, 10}, v.gr)
            assert.are.same(Vec{40, 20, 10, 30}, v.agrb)

            assert.are.same(Vec{20, 10}, v.ji)
            assert.are.same(Vec{40, 20, 10, 30}, v.ljik)
        end)

        it("to set single values", function ()
            local u = Vec{1, 2, 3, 4}
            u.x = 10
            u.y = 20
            u.z = 30
            u.w = 40
            assert.are.same(Vec.new{10, 20, 30, 40}, u)

            u = Vec{1, 2, 3, 4}
            u.r = 10
            u.g = 20
            u.b = 30
            u.a = 40
            assert.are.same(Vec.new{10, 20, 30, 40}, u)

            u = Vec{1, 2, 3, 4}
            u.i = 10
            u.j = 20
            u.k = 30
            u.l = 40
            assert.are.same(Vec.new{10, 20, 30, 40}, u)
        end)

        it("to set multiple values", function ()
            local u = Vec{1, 2, 3, 4}
            u.xy = {10, 20}
            assert.are.same(Vec{10, 20, 3, 4}, u)
            u.xyz = {11, 21, 31}
            assert.are.same(Vec{11, 21, 31, 4}, u)
            u.xyzw = {11, 21, 31, 41}
            assert.are.same(Vec{11, 21, 31, 41}, u)

            u = Vec{1, 2, 3, 4}
            u.rg = {10, 20, 3, 4}
            assert.are.same(Vec{10, 20, 3, 4}, u)
            u.rgb = {11, 21, 31}
            assert.are.same(Vec{11, 21, 31, 4}, u)
            u.rgba = {11, 21, 31, 41}
            assert.are.same(Vec{11, 21, 31, 41}, u)

            u = Vec{1, 2, 3, 4}
            u.ij = {10, 20, 3, 4}
            assert.are.same(Vec{10, 20, 3, 4}, u)
            u.ijk = {11, 21, 31}
            assert.are.same(Vec{11, 21, 31, 4}, u)
            u.ijkl = {11, 21, 31, 41}
            assert.are.same(Vec{11, 21, 31, 41}, u)
        end)

        it("to set multiple values swapped", function ()
            local u = Vec{1, 2, 3, 4}
            u.yx = {20, 10}
            assert.are.same(Vec{10, 20, 3, 4}, u)
            u.wyxz = Vec{41, 21, 11, 31}
            assert.are.same(Vec{11, 21, 31, 41}, u)

            u = Vec{1, 2, 3, 4}
            u.gr = {20, 10}
            assert.are.same(Vec{10, 20, 3, 4}, u)
            u.agrb = Vec{41, 21, 11, 31}
            assert.are.same(Vec{11, 21, 31, 41}, u)

            u = Vec{1, 2, 3, 4}
            u.ji = {20, 10}
            assert.are.same(Vec{10, 20, 3, 4}, u)
            u.ljik = Vec{41, 21, 11, 31}
            assert.are.same(Vec{11, 21, 31, 41}, u)
        end)
    end)

    describe(".dot", function ()
        it("returns dot product of two vectors", function ()
            assert.are.same(20, Vec.dot(Vec{1, 2, 3, 4}, Vec{4, 3, 2, 1}))
        end)
    end)

    describe(".allowVectorIndices", function ()
        it("allows indexing multidimensional arrays with vectors", function ()
            local m = Vec.allowVectorIndices{
                {1, 2},
                {3, 4}
            }
            assert.are.same(1, m[Vec{1, 1}])
            assert.are.same(2, m[Vec{1, 2}])
            assert.are.same(3, m[Vec{2, 1}])
            assert.are.same(4, m[Vec{2, 2}])
            assert.are.same({3, 4}, m[Vec{2}])
        end)

        it("allows setting by indexing multidimensional arrays with vectors", function ()
            local m = Vec.allowVectorIndices{
                {1, 2},
                {3, 4}
            }
            m[Vec{1, 2}] = 20
            m[Vec{2}] = {30, 40}
            assert.are.same(1, m[1][1])
            assert.are.same(20, m[1][2])
            assert.are.same(30, m[2][1])
            assert.are.same(40, m[2][2])
        end)
    end)
end)
