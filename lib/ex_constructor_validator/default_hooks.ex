defmodule ExConstructorValidator.DefaultHooks do
  @moduledoc """
  Default hook implementations.

  Implement methods below in the module with `use ExConstructorValidator`
  to override behaviour.
  """

  @doc """
  Override to make struct a custom way.
  This function ignores validity.

  By default creates the struct with the given key/value pairs.
  This is used in both `YourModule.new/2` and `YourModule.put/3`.

  If you are using [exconstructor](https://github.com/appcues/exconstructor),
  then overriding this method will be useful:

  ```
  defmodule Point do
    @enforce_keys [:x, :y]
    defstruct [:x, :y, :z]

    use ExConstructor, name: :__new__
    use ExConstructorValidator # Adds `new` and `put` dynamically

    def create_struct(args, _) do
      __new__(args)
    end

    def validate_struct(struct) do
      if struct.x < 0 or struct.y < 0 or struct.z < 0 do
        raise ArgumentError
      end

      struct
    end
  end
  """
  def create_struct(args, module) do
    Kernel.struct!(module, args)
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
