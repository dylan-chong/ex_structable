defmodule TestStruct do # TODO
  @moduledoc false
  # This is a hidden module that is only here for testing type specs
  # (which are checked when you run `mix dialyzer`).
  # Dialxir does not work on exs files, so will not work on tests.

  @enforce_keys [:length, :x, :y]
  defstruct [:length, :x, :y]

  use ExStructable
end
