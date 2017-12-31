defmodule ExStructable do
  @moduledoc """
  The `use`-able module.

  These methods are added to the module that has `use ExStructable`:

      def new(args, override_opts \\\\ []) # ...
      def put(struct = %_{}, args, override_opts \\\\ []) # ...

  `@doc`s are added to your module for the above methods. Run `mix exdoc` to
  see them.

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
  <!-- doctests. Comparing the inspected string is a workaround. -->

  And `new` fails when `validate_struct/2` fails:

      ...> Line.new(length: -2, x: 1, y: 2)
      ** (ArgumentError) Invalid length found

  Here is an example of the `put` method usage:

      ...> Line.new(length: 1, x: 1, y: 2) |> Line.put(length: 3) |> inspect()
      "%ExStructableTest.Line{length: 3, x: 1, y: 2}"

  And `put` method validation failure:

      ...> Line.new(length: 1, x: 1, y: 2) |> Line.put(length: -3, x: 2)
      ** (ArgumentError) Invalid length found

  ### Configuration

  #### Options

  The `use` macro has optional arguments. See `__using__/1`.

  You even can pass these options to the `new` and `put` methods:

      ...> Line.new([length: -3, x: 1, y: 2], [validate_struct: false])
      "%ExStructableTest.Line{length: -3, x: 1, y: 2}"

  #### Hooks

  For more optional hooks like `validate_struct/2` (see `ExStructable.Hooks`).

  ### ExConstructor Integration

  You can use [appcues/ExConstructor](https://github.com/appcues/exconstructor)
  at the same time using `use_ex_constructor_library: true`:

      iex> defmodule Line2 do
      ...>   defstruct [:length_in_cm, :x, :y]
      ...>
      ...>   use ExStructable, use_ex_constructor_library: true
      ...>
      ...>   @impl true
      ...>   def validate_struct(line, _options) do
      ...>     if line.length_in_cm <= 0 do
      ...>       raise ArgumentError, "Invalid length found"
      ...>     end
      ...>
      ...>     line
      ...>   end
      ...> end
      ...>
      ...> # We can now pass camelcase arguments
      ...> Line2.new(lengthInCm: 1, x: 1, y: 2) |> inspect()
      "%ExStructableTest.Line2{length_in_cm: 1, x: 1, y: 2}"

  And validation still fails as expected:

      ...> Line2.new(lengthInCm: -3, x: 1, y: 2) |> inspect()
      ** (ArgumentError) Invalid length found

  (Do not put `use ExConstructor` as that is added to your module when the
  option `use_ex_constructor_library` is set to a truthy value).

  If you want to pass args to `ExConstructor`:

      use ExStructable, use_ex_constructor_library: [
        # args for `use ExConstructor` here
      ]
  """

  @typedoc """
  Key value pairs to put into the struct.
  """
  @type args :: keyword | %{required(atom | String.t) => any}

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
    use_arg = Keyword.fetch!(options, :use_ex_constructor_library)

    if use_arg do
      default_args = [name: ex_constructor_new_name()]

      if is_list(use_arg) do
        Keyword.merge(default_args, use_arg)
      else
        default_args
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
  The doctest below shows the default values of the of the possible `use` and
  `override_opts`, and their descriptions.

      iex> default_options()
      [
        # Call validate_struct callback?
        validate_struct: true,
        # Use library https://github.com/appcues/exconstructor .
        # Is a boolean or Keyword List of options to be passed to
        # `use ExConstructor`.
        use_ex_constructor_library: false,
        # The name of the `new` function to define in your module.
        new_function_name: :new,
        # The name of the `put` function to define in your module.
        put_function_name: :put,
        # Throw KeyError on passing unknown key, and
        # throw ArgumentError if a key from `@enforce_keys` is missing.
        strict_keys: true
      ]
  """
  def default_options do
    # The doctest above is added to make sure that the docs get updated
    # when adding a new option.
    [
      validate_struct: true,
      use_ex_constructor_library: false,
      new_function_name: :new,
      put_function_name: :put,
      strict_keys: true,
    ]
  end

  @doc """
  Add `new` and `put` functions to the caller's module.

  * options - (Keyword List) See `default_options/0` for more all possible options.
  """
  defmacro __using__(options) do
    options = Keyword.merge(default_options(), options)

    lib_args = ex_constructor_lib_args(options)

    new_function_name = Keyword.fetch!(options, :new_function_name)
    put_function_name = Keyword.fetch!(options, :put_function_name)

    quote do
      if unquote(lib_args) do
        use ExConstructor, unquote(lib_args)
      end

      @behaviour ExStructable.Hooks

      @doc """
      Create a new struct.

      * args - (Keyword List or Map) Key-Value pairs used to create the struct.
      * override_opts - (Keyword List) Options to override existing ones. See Options
      documentation in `ExStructable` and `ExStructable.default_options/0`.
      """
      @spec unquote(new_function_name)(
        ExStructable.args,
        ExStructable.options
      ) :: ExStructable.validation_result
      def unquote(new_function_name)(args, override_opts \\ [])
      when (is_list(args) or is_map(args)) and is_list(override_opts)
      do
        merged_options = Keyword.merge(unquote(options), override_opts)

        struct = create_struct(args, merged_options)

        finish = unquote(&ExStructable.finish_creating/3)
        result = finish.(struct, merged_options, __MODULE__)

        after_new(result, merged_options)
        result
      end

      @doc """
      Alter and existing struct.

      * struct - Struct to modify. Only accepts a struct of this module's type.
      * args - (Keyword List or Map) Key-Value pairs used to override existing
      values in the given struct.
      * override_opts - See `new/2`'s override_opts.
      """
      @spec unquote(put_function_name)(
        %__MODULE__{},
        ExStructable.args,
        ExStructable.options
      ) :: ExStructable.validation_result
      def unquote(put_function_name)(struct = %_{}, args, override_opts \\ [])
      when (is_list(args) or is_map(args)) and is_list(override_opts)
      do
        unless struct.__struct__ == __MODULE__ do
          raise ArgumentError,
            "#{inspect(struct)} struct is not a %#{__MODULE__}{}"
        end

        merged_options = Keyword.merge(unquote(options), override_opts)

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
          new_function_name = ExStructable.ex_constructor_new_name()
          apply(__MODULE__, new_function_name, [args])
        else
          if Keyword.fetch!(options, :strict_keys) do
            Kernel.struct!(__MODULE__, args)
          else
            Kernel.struct(__MODULE__, args)
          end
        end
      end
      defoverridable [create_struct: 2]

      @impl ExStructable.Hooks
      def put_into_struct(args, struct, options) do
        lib_args = Keyword.fetch!(options, :use_ex_constructor_library)

        if lib_args do
          ExConstructor.populate_struct(
            struct,
            args,
            case lib_args do
              true ->
                []
              _ ->
                lib_args
            end
          )
        else
          if Keyword.fetch!(options, :strict_keys) do
            Kernel.struct!(struct, args)
          else
            Kernel.struct(struct, args)
          end
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
