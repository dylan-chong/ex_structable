defmodule ExConstructorValidator do
  @moduledoc """
  See README https://github.com/dylan-chong/ex_constructor_validator
  """

  def ex_constructor_new_name, do: :__new__

  defmacro __using__(options) do
    options = Keyword.merge([
      # call validate_struct callback?
      validate_struct: true,
      # use library https://github.com/appcues/exconstructor
      use_ex_constructor_library: false,
    ], options)

    quote do
      if unquote(Keyword.fetch!(options, :use_ex_constructor_library)) do
        use ExConstructor, name: unquote(ex_constructor_new_name())
      end

      def new(args, override_options \\ []) when is_list(override_options) do
        merged_options =
          Keyword.merge(unquote(options), override_options)
        opt = &Keyword.fetch!(merged_options, &1)
        call_hook = &ExConstructorValidator.call_hook(__MODULE__, &1, &2)

        struct = call_hook.(:create_struct, [
          args, __MODULE__, merged_options
        ])

        result = if opt.(:validate_struct) do
          validated_struct = call_hook.(:validate_struct, [
            struct, merged_options
          ])

          if validated_struct == nil do
            # To prevent accidental mistakes
            raise ExConstructorValidator.InvalidHookError,
              "validate_struct cannot return nil. "
              <> "Return the struct instead (if validation passed)."
          end

          validated_struct
        else
          struct
        end

        call_hook.(
          merged_options[:on_success] || :on_successful_new,
          [result, merged_options]
        )
        result
      end

      def put(struct = %_{}, args, override_options \\ [])
      when is_list(override_options) do
        # TODO accept struct being a map or kw list? (create overload)
        unless struct.__struct__ == __MODULE__ do
          raise ArgumentError,
            "#{inspect(struct)} struct is not a %#{__MODULE__}{}"
        end

        struct
        |> Map.from_struct
        |> Keyword.new
        |> Keyword.merge(args)
        |> new(Keyword.put(
          override_options,
          :on_success,
          :on_successful_put
        ))
      end
    end

    # TODO typespecs
    # TODO customisable args for ex_constructor lib
    # TODO customisable new/put names
    # TODO publish in hex
  end

  def call_hook(caller_module, method, method_args) do
    caller_functions = caller_module.__info__(:functions)

    module = if Keyword.has_key?(caller_functions, method) do
      caller_module
    else
      ExConstructorValidator.DefaultHooks
    end

    apply(module, method, method_args)
  end
end
