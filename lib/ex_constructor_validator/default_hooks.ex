defmodule ExConstructorValidator.DefaultHooks do
  @moduledoc "
  Default hook implementations.
  Implement methods below in the module with `use ExConstructorValidator`
  to override behaviour.
  "

  @doc """
  Override to make struct a custom way.
  The return value is the return value of YourModule.new/2.

  By default creates the struct with the given key/value pairs.
  """
  def __create_struct__(args, module) do
    struct(module, args)
  end

  @doc """
  Override to throw or return error value.
  The return value is the return value of YourModule.new/2.

  By default returns the given struct.
  """
  def __check_struct__(str) do
    str
  end
end
