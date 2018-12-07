defmodule ExStructable.TestStruct do
  @moduledoc false
  # This is a hidden module that is only here for testing type specs
  # (which are checked when you run `mix dialyzer`).
  # Dialxir does not work on exs files, so will not work on tests.

  @enforce_keys [:length]
  defstruct [:length, :x, :y]

  use ExStructable

  def create_examples do
    # These examples should not cause dialyzer errors
    new(length: 1)
    new([length: 1], strict_keys: true)

    %{length: 1}
    |> new()
    |> put(%{x: 1})
    |> put(%{y: 1}, strict_keys: false)
  end
end
