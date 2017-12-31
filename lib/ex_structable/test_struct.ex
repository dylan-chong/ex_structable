defmodule TestStruct do # TODO
  @moduledoc false
  # This is a hidden module that is only here for testing type specs
  # (which are checked when you run `mix dialyzer`).
  # Dialxir does not work on exs files, so will not work on tests.

  @enforce_keys [:length]
  defstruct [:length, :x, :y]

  use ExStructable

  def create_examples do
    # These examples should not cause dialyzer errors
    TestStruct.new([length: 1])
    TestStruct.new([length: 1], [strict_keys: true])

    TestStruct.new(%{length: 1})
    |> TestStruct.put(%{x: 1})
    |> TestStruct.put(%{y: 1}, [strict_keys: false])
  end
end
