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
      def new(args, override_options \\ []) do
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

        str = call_hook.(:__create_struct__, [args, __MODULE__])

        if opt.(:check_struct) do
          checked_str = call_hook.(:__check_struct__, [str])

          if checked_str == nil do
            # To prevent accidental mistakes
            raise(ExConstructorValidator.InvalidHookError,
              "__check_struct__ returned nil"
            )
          end

          checked_str
        else
          str
        end
      end
    end

    # TODO option to allow fallback to all default args if all args are defaultable
    # TODO ? option to not allow nil args
    # TODO At option to update

    # TODO get to work with exconstructor library
  end

end
