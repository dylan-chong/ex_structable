defmodule ExStructable do
  @moduledoc """
  The `use`-able module.

  Example usage:

  ```
  defmodule Point do
    @enforce_keys [:x, :y]
    defstruct [:x, :y, :z]

    use ExStructable # Adds `new` and `put` dynamically

    # Optional hook
    def validate_struct(struct) do
      if struct.x < 0 or struct.y < 0 or struct.z < 0 do
        raise ArgumentError
      end

      struct
    end
  end
  ```

  These methods are added to the `Point` module:

  ```
  def new(args, override_options \\\\ []) # ...
  def put(struct = %_{}, args, override_options \\\\ []) # ...
  ```

  So you can do things like this:

  ```
  Point.new(x: 1, y: 2)
  # => %Point{x: 1, y: 2, z: nil}

  Point.new(x: -1, y: 2)
  # ArgumentError: Fails validation, as expected

  Point.new(x: 1, y: 2) |> Point.put(x: 3)
  # => %Point{x: 3, y: 2, z: nil}

  Point.new(x: 1, y: 2) |> Point.put(x: -1)
  # ArgumentError: Fails validation, as expected
  ```

  For more optional hooks like `validate_struct/2` (see
  `ExStructable.Hooks`).

  See [README](#{ExStructable.Mixfile.github_url()}) for more info.
  """

  # TODO Documentation comments on new and put methods
  # TODO tyepsesc on new and put methods
  # TODO customisable new/put names

  @typedoc "Key value pairs to put into the struct."
  @type args :: keyword | map
  @typedoc ""
  @type options :: keyword
  @typedoc """
  Usually is a struct, may not be if validate_struct/2 is overriden and
  implemented differently.
  """
  @type validation_result :: struct | any

  @doc false
  def ex_constructor_new_name, do: :__new__

  @doc false
  def ex_constructor_lib_args(options) do
    use_option = Keyword.fetch!(options, :use_ex_constructor_library)

    if use_option do
      default_options = [name: ex_constructor_new_name()]

      if is_list(use_option) do
        Keyword.merge(default_options, use_option)
      else
        default_options
      end
    else
      nil
    end
  end

  @doc false
  def finish_creating(struct, merged_options, module) do
    if Keyword.fetch!(merged_options, :validate_struct) do
      validated_struct = module.validate_struct(struct, merged_options)

      if validated_struct == nil do
        # To prevent accidental mistakes
        raise ExStructable.InvalidHookError,
        "validate_struct cannot return nil. "
        <> "Return the struct instead (if validation passed)."
      end

      validated_struct
    else
      struct
    end
  end

  defmacro __using__(options) do
    options = Keyword.merge([
      # call validate_struct callback?
      validate_struct: true,
      # use library https://github.com/appcues/exconstructor
      use_ex_constructor_library: false, # boolean, or kw list
    ], options)

    lib_args = ex_constructor_lib_args(options)

    quote do
      if unquote(lib_args) do
        use ExConstructor, unquote(lib_args)
      end

      @behaviour ExStructable.Hooks

      def new(args, override_options \\ [])
      when (is_list(args) or is_map(args)) and is_list(override_options)
      do
        merged_options = Keyword.merge(unquote(options), override_options)

        struct = create_struct(args, merged_options)

        finish = unquote(&ExStructable.finish_creating/3)
        result = finish.(struct, merged_options, __MODULE__)

        after_new(result, merged_options)
        result
      end

      def put(struct = %_{}, args, override_options \\ [])
      when (is_list(args) or is_map(args)) and is_list(override_options)
      do
        unless struct.__struct__ == __MODULE__ do
          raise ArgumentError,
            "#{inspect(struct)} struct is not a %#{__MODULE__}{}"
        end

        merged_options = Keyword.merge(unquote(options), override_options)

        new_struct = put_into_struct(args, struct, merged_options)

        finish = unquote(&ExStructable.finish_creating/3)
        result = finish.(new_struct, merged_options, __MODULE__)

        after_put(result, merged_options)
        result
      end

      # ExStructable.Hooks default implementations:

      @impl ExStructable.Hooks
      def create_struct(args, options) do
        if Keyword.fetch!(options, :use_ex_constructor_library) do
          apply(__MODULE__, ExStructable.ex_constructor_new_name(), [args])
        else
          Kernel.struct!(__MODULE__, args)
        end
      end
      defoverridable [create_struct: 2]

      @impl ExStructable.Hooks
      def put_into_struct(args, struct, options) do
        lib_args = Keyword.fetch!(options, :use_ex_constructor_library)

        if lib_args do
          ExConstructor.populate_struct(struct, args, case lib_args do
            true -> []
            _ -> lib_args
          end)
          else
            Kernel.struct!(struct, args)
        end
      end
      defoverridable [put_into_struct: 3]

      @impl ExStructable.Hooks
      def validate_struct(struct, _options) do
        struct
      end
      defoverridable [validate_struct: 2]

      @impl ExStructable.Hooks
      def after_new(_result, _options) do
        # Stub
      end
      defoverridable [after_new: 2]

      @impl ExStructable.Hooks
      def after_put(_result, _options) do
        # Stub
      end
      defoverridable [after_put: 2]

    end

  end
end
