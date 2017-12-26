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

  test "new creates with all params" do
    expected = %ABCStruct{a: 1, b: 2, c: {4, 5}}
    assert ABCStruct.new(a: 1, b: 2, c: {4, 5}) == expected
  end

  test "new creates with all non-default params" do
    expected = %ABCStruct{a: 1, b: 2, c: 3}
    assert ABCStruct.new(a: 1, b: 2) == expected
  end

  test "new fails when required param is not passed (:a)" do
    assert_raise(
      ArgumentError,
      ~r".*:a.*",
      fn -> ABCStruct.new([]) end
    )
  end

  describe "when passing an invalid parameter" do
    test "new fails with default __using__ options" do
      assert_raise(
        ArgumentError,
        ~r"",
        fn -> ABCStruct.new([a: 1, invalid: 2]) end
      )
    end

    test "new creates when require_no_invalid_args: false" do
      expected = %DEStruct{d: 1, e: 2}
      assert DEStruct.new(d: 1, e: 2, invalid: 3) == expected
    end

  end

  # TODO test new with invalid params

  # TODO get to work with exconstructor library
end
