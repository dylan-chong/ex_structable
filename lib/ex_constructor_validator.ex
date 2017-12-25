defmodule ExConstructorValidator do
  @moduledoc """
  Documentation for ExConstructorValidator.
  """

  defmacro __using__(options) do
    quote do
      import ExConstructorValidator # TODO remove

      def new(args) do
        # TODO key args may be strings
        arg_keys = args |> Map.new |> Map.keys |> MapSet.new
        required_keys = @enforce_keys |> MapSet.new
        if not MapSet.subset?(required_keys, arg_keys) do
          raise(
            ArgumentError,
            "Requires keys #{required_keys |> Enum.to_list |> inspect} "
            <> "but only #{arg_keys |> Enum.to_list |> inspect} "
            <> "were present"
            )
        end

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

end
