defmodule ExConstructorValidator do
  @moduledoc """
  See README https://github.com/dylan-chong/ex_constructor_validator
  """

  defmacro __using__(options) do
    options = Keyword.merge([
      require_no_invalid_args: true,
      use_enforce_keys: true,
      validate_struct: true,
      allow_nil_args: true, # TODO NEXT
    ], options)

    quote do
      def new(args, override_options \\ [])
      when is_list(args) and is_list(override_options) do
        alias ExConstructorValidator.Helper

        merged_options =
          Keyword.merge(unquote(options), override_options)
        opt = &Keyword.fetch!(merged_options, &1)
        call_hook = &Helper.call_hook(__MODULE__, &1, &2)

        if opt.(:use_enforce_keys) do
          Helper.require_keys(args, @enforce_keys)
        end
        if opt.(:require_no_invalid_args) do
          Helper.require_no_invalid_args(args, __MODULE__)
        end

        struct = call_hook.(:create_struct, [args, __MODULE__])

        result = if opt.(:validate_struct) do
          validated_struct = call_hook.(:validate_struct, [struct])

          if validated_struct == nil do
            # To prevent accidental mistakes
            raise ExConstructorValidator.InvalidHookError,
              "validate_struct cannot return nil"
          end

          validated_struct
        else
          struct
        end

        unless merged_options[:not_new] do
          call_hook.(:on_successful_new, [result])
        end
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
          |> new(Keyword.put(override_options, :not_new, true))

        Helper.call_hook(__MODULE__, :on_successful_put, [result])
        result
      end
    end

    # TODO option to allow fallback to all default args if all args are defaultable
    # TODO ? option to not allow nil args
    # TODO At option to update

    # TODO get to work with exconstructor library
    # TODO typespecs
    # TODO publish in hex
  end

end
