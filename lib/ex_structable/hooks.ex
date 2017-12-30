defmodule ExStructable.Hooks do
  @moduledoc """
  Behaviour for default hook implementations.

  Implement methods below in the module with `use ExStructable`
  to override behaviour (default implementations are provided).

  Be sure to use `@impl true` above the hook implementation to add compile-time
  warnings about incorrect hook definitions.
  """

  @doc """
  Override to make struct a custom way.
  This function ignores validity.

  By default creates the struct with the given key/value args.
  This is used in `YourModule.new/2`.
  """
  @callback create_struct(
    args :: ExStructable.args,
    options :: ExStructable.options
  ) :: struct

  @doc """
  Override to put args into struct in a custom way, and return new struct.
  This function ignores validity.

  By default puts the given key/value args into the given struct.
  This is used in `YourModule.put/3`.
  """
  @callback put_into_struct(
    args :: ExStructable.args,
    struct,
    options :: ExStructable.options
  ) :: struct

  @doc """
  Override to raise or return a custom error value such as `{:error, struct}`.

  The return value is the return value of YourModule.new/2, so usually returns
  are struct when validation is successful.

  By default returns the given struct without any checking.

  You can even define a hook using guards such as:
  ```
  @impl true
  def validate_struct(struct = %Line{length: length}) when length > 0 do
    struct
  end
  ```
  because it raises a FunctionClauseError when the guard isn't matched.
  """
  @callback validate_struct(
    struct,
    options :: ExStructable.options
  ) :: ExStructable.validation_result

  @doc """
  Called when a struct has passed validation after a call to
  `YourModule.new/2`. Does not get called if `validate_struct` throws an
  exception.

  Override to add custom functionality.
  """
  @callback after_new(
    validation_result :: ExStructable.validation_result,
    options :: ExStructable.options
  ) :: none

  @doc """
  Called when a struct has passed validation after a call to
  `YourModule.put/3`. Does not get called if `validate_struct` throws an
  exception.

  Override to add custom functionality.
  """
  @callback after_put(
    validation_result :: ExStructable.validation_result,
    options :: ExStructable.options
  ) :: none

end
