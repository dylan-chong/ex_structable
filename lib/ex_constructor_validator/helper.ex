defmodule ExConstructorValidator.Helper do
  @moduledoc "Helper functionality for ExConstructorValidator"

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

