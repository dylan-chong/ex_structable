defmodule ExConstructorValidatorTest do
  use ExUnit.Case
  doctest ExConstructorValidator

  defmodule ExampleStruct do
    @enforce_keys [:a]
    defstruct [:a, b: [2], c: 3]
    use ExConstructorValidator
  end

  test "new creates with all params" do
    expected = %ExampleStruct{a: 1, b: 2, c: {4, 5}}
    assert ExampleStruct.new(a: 1, b: 2, c: {4, 5}) == expected
  end

  test "new creates with all non-default params" do
    expected = %ExampleStruct{a: 1, b: 2, c: 3}
    assert ExampleStruct.new(a: 1, b: 2) == expected
  end

  test "new fails when required param is not passed (:a)" do
    assert_raise(
      ArgumentError,
      ~r".*:a.*",
      fn -> ExampleStruct.new([]) end
    )
  end

  # TODO test new with missing non-default param
  # TODO test new with invalid params
  # TODO test new with wrong name param

  # TODO test new with wrong name param

  # TODO get to work with exconstructor library
end
