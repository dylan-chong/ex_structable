defmodule TestStruct do # TODO
  @moduledoc false
  # This is a hidden module that is only here for testing type specs.
  # Dialxir does not work on exs files, so will not work on tests.

  @enforce_keys [:length, :x, :y]
  defstruct [:length, :x, :y]

  use ExStructable

  @impl true
  def validate_struct(line, _options) do
    if line.length <= 0 do
      raise ArgumentError, "Invalid length found"
    end

    line
  end
end
