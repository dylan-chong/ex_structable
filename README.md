# ExConstructorValidator

A personal exercise with macros (basically pretending that `Kernel.struct!/2`
doesn't exist).

Allows:
- Custom validation of the `YourModule.new/2` args, which `%YourModule{args}`
does not allow
- Raising errors when invalid key is passed as args
- Raising errors when an `@enforce_keys` key is passed to `YourModule.new/2`
- named-parameters in `YourModule.new/2`

### The Problem

```elixir
defmodule Point do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  def new(args) do
    args = Keyword.new(args)

    if args[:x] < 0, do: raise ArgumentError
    if args[:y] < 0, do: raise ArgumentError
    if args[:z] < 0, do: raise ArgumentError

    struct(__MODULE__, args)
  end
end

test "boring example" do
  # PASS. Raises ArgumentError, as it should
  assert_raise ArgumentError,
      fn -> Point.new(x: -1, y: 2) end
  # PASS. Creates new point successfully, as it should
  Point.new(x: 1, y: 2)

  # FAIL! Creates new Point, but it should not! (See Point.@enforce_keys)
  assert_raise ArgumentError,
      fn -> Point.new(x: 1) end
  # FAIL! Creates a Point, but :invalid is not a valid key!
  assert_raise ArgumentError,
      fn -> Point.new(x: 1, invalid: 1) end
  # FAIL! Creates a Point, but x < 0 !
  assert_raise ArgumentError,
      fn -> %Point{x: -2, invalid: 1} end
end

```

### The solution

```elixir

defmodule BetterPoint do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  use ExConstructorValidator # Add some (mild) magic!

  def validate_struct(struct) do
    if struct.x < 0, do: raise ArgumentError
    if struct.y < 0, do: raise ArgumentError
    if struct.z < 0, do: raise ArgumentError
    struct
  end
end

test "example using ExConstructorValidator" do
  # PASS. raises ArgumentError, as it should
  assert_raise ArgumentError,
      fn -> BetterPoint.new(x: -1, y: 2) end
  # PASS. creates new point successfully, as it should
  BetterPoint.new(x: 1, y: 2)

  # PASS! raises as it should
  assert_raise ArgumentError,
      fn -> BetterPoint.new(x: 1) end
  # PASS! raises as it should
  assert_raise ArgumentError,
      fn -> BetterPoint.new(x: 1, invalid: 1) end
end
```

## Configuration

The `use` has optional arguments. See the [top of
`ExConstructorValidator.__using__/1` to see all their default
values](https://github.com/dylan-chong/ex_constructor_validator/blob/master/lib/ex_constructor_validator.ex#L7).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_constructor_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_constructor_validator, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_constructor_validator](https://hexdocs.pm/ex_constructor_validator).

