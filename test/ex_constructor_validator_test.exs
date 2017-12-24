defmodule ExConstructorValidatorTest do
  use ExUnit.Case
  doctest ExConstructorValidator

  test "greets the world" do
    assert ExConstructorValidator.hello() == :world
  end
end
