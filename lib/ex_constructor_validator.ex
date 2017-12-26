defmodule ExConstructorValidator do
  @moduledoc """
  Documentation for ExConstructorValidator.
  """

  defmacro __using__(options) do
    options = Keyword.merge([
      require_no_invalid_args: true,
      use_enforce_keys: true,
      check_struct: true,
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

        struct = call_hook.(:__create_struct__, [args, __MODULE__])

        if opt.(:check_struct) do
          checked_struct = call_hook.(:__check_struct__, [struct])

          if checked_struct == nil do
            # To prevent accidental mistakes
            raise ExConstructorValidator.InvalidHookError,
              "__check_struct__ cannot return nil"
          end

          checked_struct
        else
          struct
        end
      end

      def update(struct = %_{}, args, override_options \\ [])
      when is_list(args) and is_list(override_options) do
        # TODO accept struct being a map or kw list?
        unless struct.__struct__ == __MODULE__ do
          raise ArgumentError,
            "#{inspect(struct)} struct is not a %#{__MODULE__}{}"
        end

        struct
        |> Map.from_struct
        |> Keyword.new
        |> Keyword.merge(args)
        |> new(override_options)
      end
    end

    # TODO NEXT update method
    # TODO AFTER renamed check construct to validate struct
    # TODO AFTER new/update method hooks

    # TODO option to allow fallback to all default args if all args are defaultable
    # TODO ? option to not allow nil args
    # TODO At option to update

    # TODO get to work with exconstructor library
  end

end
