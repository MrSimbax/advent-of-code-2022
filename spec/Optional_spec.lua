local Optional = require "libs/Optional"

describe("Optional", function ()
    it("holds the payload when created with payload", function ()
        assert.are.same(1, Optional.new(1):value())
    end)

    it("can be created with no value", function ()
        assert.has_not.error(function () Optional.new() end)
    end)

    it("throws error upon access if it has no payload", function ()
        assert.has.error(function () Optional.new():value() end)
    end)

    it(".empty() returns an empty optional", function ()
        assert.has.error(function () Optional.empty():value() end)
    end)

    it("can be checked whether it has payload", function ()
        assert.is.False(Optional.new():hasValue())
        assert.is.False(Optional.empty():hasValue())
        assert.is.True(Optional.new(1):hasValue())

        assert.is.True(Optional.new():isEmpty())
        assert.is.True(Optional.empty():isEmpty())
        assert.is.False(Optional.new(1):isEmpty())
    end)

    describe("==", function ()
        it("returns true when both optionals are empty", function ()
            assert.is.True(Optional.new() == Optional.new())
            assert.is.True(Optional.new() == Optional.empty())
        end)

        it("returns true when both optionals carry the same payload", function ()
            assert.is.True(Optional.new(1) == Optional.new(1))
        end)

        it("returns false when optionals carry different payloads", function ()
            assert.is.False(Optional.new(1) == Optional.new(2))
            assert.is.False(Optional.new(2) == Optional.new(1))
        end)

        it("returns false when one optional carries payload and the other does not", function ()
            assert.is.False(Optional.new(1) == Optional.new())
            assert.is.False(Optional.new() == Optional.new(1))
        end)
    end)
end)
