defmodule ExStructable.DefaultHooks do
  @moduledoc """
  Default hook implementations.

  Implement methods below in the module with `use ExStructable`
  to override behaviour.
  """

  @doc """
  Override to make struct a custom way.
  This function ignores validity.

  By default creates the struct with the given key/value pairs.
  This is used in `YourModule.new/2`.
  """
  def create_struct(args, module, options) do
    if Keyword.fetch!(options, :use_ex_constructor_library) do
      apply(module, ExStructable.ex_constructor_new_name(), [args])
    else
      Kernel.struct!(module, args)
    end
  end

  @doc """
  Override to put args into struct in a custom way.
  This function ignores validity.

  By default creates the struct with the given key/value pairs.
  This is used in YourModule.put/3`.
  """
  def put_into_struct(args, struct, options) do
    if Keyword.fetch!(options, :use_ex_constructor_library) do
      # TODO fix camel case in args not overriding
      apply(struct.__struct__, ExStructable.ex_constructor_new_name(), [
        Map.merge(struct, args)
      ])
    else
      Kernel.struct!(struct, args)
    end
  end

  @doc """
  Override to raise or return a custom error value such as `{:error, struct}`.

  The return value is the return value of YourModule.new/2.

  By default returns the given struct.

  You can even define a hook using guards such as:
  ```
  def validate_struct(struct = %MyStruct{a: a}) when a > 0 do
    struct
  end
  ```
  because it raises a FunctionClauseError when the guard isn't matched.
  """
  def validate_struct(struct, _options) do
    struct
  end

  @doc """
  Called when a struct has passed validation after a call to
  `YourModule.new/2`. Does not get called if `validate_struct` throws an
  exception.

  Override to add custom functionality.
  """
  def after_new(_result, _options) do
    # Stub
  end

  @doc """
  Called when a struct has passed validation after a call to
  `YourModule.put/3`. Does not get called if `validate_struct` throws an
  exception.

  Override to add custom functionality.
  """
  def after_put(_result, _options) do
    # Stub
  end

end
