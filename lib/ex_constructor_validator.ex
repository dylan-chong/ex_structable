defmodule ExConstructorValidator do
  @moduledoc """
  See README https://github.com/dylan-chong/ex_constructor_validator
  """

  defmacro __using__(options) do
    options = Keyword.merge([
      validate_struct: true,
    ], options)

    quote do
      def new(args, override_options \\ [])
      when is_list(args) and is_list(override_options) do
        alias ExConstructorValidator.Helper

        merged_options =
          Keyword.merge(unquote(options), override_options)
        opt = &Keyword.fetch!(merged_options, &1)
        call_hook = &Helper.call_hook(__MODULE__, &1, &2)

        struct = call_hook.(:create_struct, [args, __MODULE__])

        result = if opt.(:validate_struct) do
          validated_struct = call_hook.(:validate_struct, [struct])

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
          [result]
        )
        result
      end

      def put(struct = %_{}, args, override_options \\ [])
      when is_list(args) and is_list(override_options) do
        alias ExConstructorValidator.Helper

        # TODO accept struct being a map or kw list?
        unless struct.__struct__ == __MODULE__ do
          raise ArgumentError,
            "#{inspect(struct)} struct is not a %#{__MODULE__}{}"
        end

        result =
          struct
          |> Map.from_struct
          |> Keyword.new
          |> Keyword.merge(args)
          |> new(Keyword.put(
            override_options,
            :on_success,
            :on_successful_put
          ))

        result
      end
    end

    # TODO get to work with exconstructor library
    # TODO typespecs
    # TODO publish in hex
  end

end
