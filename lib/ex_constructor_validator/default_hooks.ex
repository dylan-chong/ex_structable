defmodule ExConstructorValidator.DefaultHooks do
  @moduledoc """
  Default hook implementations.

  Implement methods below in the module with `use ExConstructorValidator`
  to override behaviour.
  """

  @doc """
  Override to make struct a custom way.
  The return value is the return value of YourModule.new/2.

  By default creates the struct with the given key/value pairs.
  """
  def __create_struct__(args, module) do
    Kernel.struct(module, args)
  end

  @doc """
  Override to throw or return a custom error value such as `{:error, struct}`.

  The return value is the return value of YourModule.new/2.

  By default returns the given struct.

  You can even define a hook using guards such as:
  ```
  def __validate_struct__(struct = %MyStruct{a: a}) when a > 0 do
    struct
  end
  ```
  because it throws a FunctionClauseError when the guard isn't
  matched.
  """
  def __validate_struct__(struct) do
    struct
  end
end
