defmodule ExStructable do
  @moduledoc """
  The `use`-able module.

  These methods are added to the module that has `use ExStructable`:

      def new(args, override_options \\\\ []) # ...
      def put(struct = %_{}, args, override_options \\\\ []) # ...

  Example usage:

      iex> defmodule Line do
      ...>   @enforce_keys [:length, :x, :y]
      ...>   defstruct [:length, :x, :y]
      ...>
      ...>   use ExStructable # Adds `new` and `put` dynamically
      ...>
      ...>   # Optional hook
      ...>   @impl true
      ...>   def validate_struct(line, _options) do
      ...>     if line.length <= 0 do
      ...>       raise ArgumentError, "Invalid length found"
      ...>     end
      ...>
      ...>     line
      ...>   end
      ...> end
      ...>
      ...> Line.new(length: 1, x: 1, y: 2) |> inspect()
      "%ExStructableTest.Line{length: 1, x: 1, y: 2}"

  <!-- For some reason you can't create structs as the required answer in -->
  <!-- doctests. Comaring the inspected string is a workaround. -->

  And `new` fails when `validate_struct/2` fails:

      ...> Line.new(length: -2, x: -1, y: 2)
      ** (ArgumentError) Invalid length found

  Here is an example of the `put` method usage:

      ...> Line.new(length: 1, x: 1, y: 2) |> Line.put(length: 3) |> inspect()
      "%ExStructableTest.Line{length: 3, x: 1, y: 2}"

  And `put` method validation failure:

      ...> Line.new(length: 1, x: 1, y: 2) |> Line.put(length: -3, x: 2)
      ** (ArgumentError) Invalid length found

  ### Configuration

  For more optional hooks like `validate_struct/2` (see `ExStructable.Hooks`).

  The `use` (the `__using__` macro) has optional arguments. See
  `ExStructable.default_options/0` for more info.
  """

  # TODO move ExConstructor example from readme here
  # TODO Documentation comments on new and put methods
  # TODO tyepsesc on new and put methods
  # TODO customisable strict_keys
  # TODO customisable new/put names

  @typedoc """
  Key value pairs to put into the struct.
  """
  @type args :: keyword | %{required(atom) => any}

  @typedoc """
  Options passed to `use ExStructable`, `new`, and `put`.
  """
  @type options :: keyword

  @typedoc """
  Usually is a struct, may not be if validate_struct/2 is overriden and
  returns something else.
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

  @doc """
  The doctest shows the default values of the of the possible options, and
  their descriptions.

    iex> default_options()
    [
      # Call validate_struct callback?
      validate_struct: true,
      # Use library https://github.com/appcues/exconstructor .
      # Is a boolean or Keyword List of options to be passed to
      # `use ExConstructor`.
      use_ex_constructor_library: false,
    ]
  """
  def default_options do
    # The doctest above is added to make sure that the docs get updated
    # when adding a new option.
    [
      validate_struct: true,
      use_ex_constructor_library: false,
    ]
  end

  defmacro __using__(options) do
    options = Keyword.merge(default_options(), options)

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
