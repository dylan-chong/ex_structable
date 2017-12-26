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

        if opt.(:use_enforce_keys) do
          Helper.require_keys(args, @enforce_keys)
        end
        if opt.(:require_no_invalid_args) do
          Helper.require_no_invalid_args(args, __MODULE__)
        end

        str = __call_hook__(:__create_struct__, [args, __MODULE__])

        if opt.(:check_struct) do
          checked_str = __call_hook__(:__check_struct__, [str])

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

      def __call_hook__(method, method_args) do
        module =
          if __MODULE__.__info__(:functions) |> Keyword.has_key?(method) do
            __MODULE__
          else
            ExConstructorValidator.DefaultHooks
          end

        apply(module, method, method_args)
      end
    end

    # TODO option to allow fallback to all default args if all args are defaultable
    # TODO ? option to not allow nil args
    # TODO At option to update

    # TODO get to work with exconstructor library
  end

  defmodule Helper do
    @moduledoc "Helper functionality for ExConstructorValidator"

    def require_keys(args, enforce_keys) do
      arg_keys =
        args
        |> Map.new
        |> Map.keys
        |> MapSet.new
      required_keys = enforce_keys |> MapSet.new

      if not MapSet.subset?(required_keys, arg_keys) do
        raise(
          ArgumentError,
          "Requires keys #{required_keys |> Enum.to_list |> inspect} "
          <> "but only #{arg_keys |> Enum.to_list |> inspect} "
          <> "were given"
        )
      end
    end

    def require_no_invalid_args(args, module) do
      arg_keys =
        args
        |> Map.new
        |> Map.keys
        |> MapSet.new
      valid_keys =
        module
        |> struct([])
        |> Map.from_struct
        |> Map.keys
        |> MapSet.new

      if not MapSet.subset?(arg_keys, valid_keys) do
        raise(
          ArgumentError,
          "Allowed keys are #{valid_keys |> Enum.to_list |> inspect} "
          <> "but #{arg_keys |> Enum.to_list |> inspect} "
          <> "were given"
        )
      end
    end
  end

  defmodule DefaultHooks do
    @moduledoc "Default hook implementation"

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

  defmodule InvalidHookError do
    defexception [:message]

    def exception(message) do
      %InvalidHookError{message: message}
    end
  end
end
