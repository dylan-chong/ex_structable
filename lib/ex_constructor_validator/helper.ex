defmodule ExConstructorValidator.Helper do
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

  def call_hook(caller_module, method, method_args) do
    caller_functions = caller_module.__info__(:functions)

    module =
      if Keyword.has_key?(caller_functions, method) do
        caller_module
      else
        ExConstructorValidator.DefaultHooks
      end

    apply(module, method, method_args)
  end
end

