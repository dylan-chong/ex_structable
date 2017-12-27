defmodule ExStructable.InvalidHookError do
  defexception [:message]

  def exception(message) do
    %ExStructable.InvalidHookError{message: message}
  end
end
