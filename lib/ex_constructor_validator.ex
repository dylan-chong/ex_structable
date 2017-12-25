defmodule ExConstructorValidator do
  @moduledoc """
  Documentation for ExConstructorValidator.
  """

  defmacro __using__(options) do
    quote do
      def new(args) do
        alias ExConstructorValidator.Helper

        Helper.require_keys(args, @enforce_keys)
        create_struct(args)
      end

      def create_struct(args) do
        struct(__MODULE__, args)
      end

    end

    # TODO check args

    # TODO option to allow fallback to all default args if all args are defaultable
    # TODO option to allow no enforce_keys
    # TODO ? option to not allow nil args
  end

  defmodule Helper do
    def require_keys(args, enforce_keys) do
      arg_keys = args |> Map.new |> Map.keys |> MapSet.new
      required_keys = enforce_keys |> MapSet.new

      if not MapSet.subset?(required_keys, arg_keys) do
        raise(
          ArgumentError,
          "Requires keys #{required_keys |> Enum.to_list |> inspect} "
          <> "but only #{arg_keys |> Enum.to_list |> inspect} "
          <> "were present"
        )
      end
    end
  end

end
