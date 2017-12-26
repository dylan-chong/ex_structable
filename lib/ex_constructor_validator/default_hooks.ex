defmodule ExConstructorValidator.DefaultHooks do
  @moduledoc """
  Default hook implementations.

  Implement methods below in the module with `use ExConstructorValidator`
  to override behaviour.
  """

  @doc """
  Override to make struct a custom way.
  The return value is the return value of YourModule.new/2.
  This function ignores validity.

  By default creates the struct with the given key/value pairs.
  """
  def create_struct(args, module) do
    Kernel.struct(module, args)
  end

  @doc """
  Override to throw or return a custom error value such as `{:error, struct}`.

  The return value is the return value of YourModule.new/2.

  By default returns the given struct.

  You can even define a hook using guards such as:
  ```
  def validate_struct(struct = %MyStruct{a: a}) when a > 0 do
    struct
  end
  ```
  because it throws a FunctionClauseError when the guard isn't
  matched.
  """
  def validate_struct(struct) do
    struct
  end

  @doc """
  Called when a struct has passed validation after a call to
  `YourModule.new/2`.

  Override to add custom functionality.
  """
  def on_successful_new(struct) do
    # Stub
  end

  @doc """
  Called when a struct has passed validation after a call to
  `YourModule.put/3`.

  Override to add custom functionality.
  """
  def on_successful_put(struct) do
    # Stub
  end

end
