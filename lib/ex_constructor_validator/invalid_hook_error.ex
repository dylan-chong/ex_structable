defmodule ExConstructorValidator.InvalidHookError do
  defexception [:message]

  def exception(message) do
    %ExConstructorValidator.InvalidHookError{message: message}
  end
end
