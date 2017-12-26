defmodule ExConstructorValidatorTest do
  use ExUnit.Case
  doctest ExConstructorValidator

  defmodule ABCStruct do
    @enforce_keys [:a]
    defstruct [:a, b: [2], c: 3]
    use ExConstructorValidator
  end

  defmodule DEStruct do
    defstruct [:d, :e]
    use ExConstructorValidator, require_no_invalid_args: false
  end

  defmodule FStruct do
    defstruct [:f]
    use ExConstructorValidator

    def __check_struct__(%FStruct{f: f}) do
      if f < 0 do
        raise ArgumentError, "invalid param"
      end
    end
  end

  describe "new creates" do
    test "with all params" do
      expected = %ABCStruct{a: 1, b: 2, c: {4, 5}}
      assert ABCStruct.new(a: 1, b: 2, c: {4, 5}) == expected
    end

    test "with all non-default params" do
      expected = %ABCStruct{a: 1, b: 2, c: 3}
      assert ABCStruct.new(a: 1, b: 2) == expected
    end
  end

  describe "when required param is not passed" do
    test "new fails with default options" do
      assert_raise(
        ArgumentError,
        ~r".*:a.*",
        fn -> ABCStruct.new([]) end
      )
    end

    test "new creates when use_enforce_keys is false" do
      expected = %ABCStruct{a: nil, b: [2], c: 3}
      assert ABCStruct.new([], [use_enforce_keys: false]) == expected
    end
  end

  describe "when passing an invalid parameter" do
    test "new fails with default options" do
      assert_raise(
        ArgumentError,
        ~r"",
        fn -> ABCStruct.new([a: 1, invalid: 2]) end
      )
    end

    test "new creates when __using__ require_no_invalid_args: false" do
      expected = %DEStruct{d: 1, e: 2}
      assert DEStruct.new(d: 1, e: 2, invalid: 3) == expected
    end

    test "new creates when passing require_no_invalid_args: false" do
      expected = %ABCStruct{a: 1, b: [2], c: 3}
      assert expected == ABCStruct.new([a: 1, invalid: 3], [
        require_no_invalid_args: false
      ])
    end
  end

  describe "when __check_struct__ is overriden" do
    test "new passes with valid params" do
      FStruct.new(f: 1)
    end

    test "new fails with invalid param" do
      assert_raise(
        ArgumentError,
        "invalid param",
        fn -> FStruct.new(f: -1) end
      )
    end

    #TODO Optioned it to disable check
  end

end
