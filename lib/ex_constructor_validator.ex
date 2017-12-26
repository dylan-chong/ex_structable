defmodule ExConstructorValidator do
  @moduledoc """
  Documentation for ExConstructorValidator.
  """

  defmacro __using__(options) do
    options = Keyword.merge([
      require_no_invalid_args: true
    ], options)

    quote do
      def new(args) do
        alias ExConstructorValidator.Helper

        Helper.require_keys(args, @enforce_keys)
        if unquote(Keyword.fetch!(options, :require_no_invalid_args)) do
          Helper.require_no_invalid_args(args, __MODULE__)
        end

        create_struct(args)
      end

      def create_struct(args) do
        struct(__MODULE__, args)
      end

    end

    # TODO check args

    # TODO option to allow fallback to all default args if all args are defaultable
    # TODO NEXT option to allow no enforce_keys
    # TODO ? option to not allow nil args
  end

  defmodule Helper do
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

end
