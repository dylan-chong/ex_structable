# ExStructable

<!-- If this is changed, update mix.exs.description/1 -->

Customisable library that reduces boilerplate to do with struct creation.
Allows you validate your structs when they are created and updated.

Hex docs can be found
[here](https://hexdocs.pm/ex_structable/ExStructable.html).

## Installation

The package can be installed by adding `ex_structable` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_structable, "~> 0.1.0"},
  ]
end
```

## The Problem

If you want to write some validation for your struct, you need to write the
boilerplate `new` and `put` methods manually.

```elixir
defmodule Point do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  def new(args) do
    args = Keyword.new(args)

    __MODULE__
    |> Kernel.struct!(args)
    |> validate_struct()
  end

  def put(struct, args) do
    args = Keyword.new(args)

    struct
    |> Kernel.struct!(args)
    |> validate_struct()
  end

  def validate_struct(struct) do
    if struct.x < 0 or struct.y < 0 or struct.z < 0 do
      raise ArgumentError
    end

    struct
  end
end

Point.new(x: 1, y: 2)
# => %Point{x: 1, y: 2, z: nil}
Point.new(x: -1, y: 2)
# Fails validation, as expected
```

And if you don't want to bother with validation yet, you might want to still
add `new` and `put` methods to be consistent (or to make it easier to add
validation later).

```elixir
defmodule PointNoValidation do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  def new(args) do
    args = Keyword.new(args)

    __MODULE__
    |> Kernel.struct!(args)
    |> validate_struct()
  end

  def put(struct, args) do
    args = Keyword.new(args)

    struct
    |> Kernel.struct!(args)
    |> validate_struct()
  end

  def validate_struct(struct) do
    struct
  end
end

PointNoValidation.new(x: 1, y: 2)
# => %PointNoValidation{x: 1, y: 2, z: nil} # Still works!
```

And you have to write this boilerplate for every module you have! That can be a
lot of duplication!

## The Solution

By the magic of Elixir macros, we can remove the duplication!

```elixir
defmodule Point do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  use ExStructable # Adds `new` and `put` dynamically

  def validate_struct(struct) do
    if struct.x < 0 or struct.y < 0 or struct.z < 0 do
      raise ArgumentError
    end

    struct
  end
end

Point.new(x: 1, y: 2)
# => %Point{x: 1, y: 2, z: nil} # Still works!
Point.new(x: -1, y: 2)
# Fails validation, as expected
```

And when we don't want validation...

```elixir
defmodule PointNoValidation do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  use ExStructable # Adds `new` and `put` dynamically
end

PointNoValidation.new(x: 1, y: 2)
# => %PointNoValidation{x: 1, y: 2, z: nil} # Still works!
```

## Configuration

### __using__ arguments

The `use` has optional arguments. See the [top of
`ExStructable.__using__/1` to see all their default
values](https://github.com/dylan-chong/ex_structable/blob/master/lib/ex_structable.ex#L43).

### Customisable Hooks

[See this file to see what looks you can
implement.](https://github.com/dylan-chong/ex_structable/blob/master/lib/ex_structable/default_hooks.ex).

### ExConstructor Support

You can use [appcues/ExConstructor](https://github.com/appcues/exconstructor)
at the same time using:

```elixir
defmodule PointNoValidation do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  use ExStructable, use_ex_constructor_library: true
end

Point.new(x: 1, y: 2)
# => %Point{x: 1, y: 2, z: nil}

Point.new(%{x: 1, y: 2})
# => %Point{x: 1, y: 2, z: nil}
```

(do not put `use ExConstructor`).

Or if you want to pass args to `ExConstructor`:

```elixir
defmodule PointNoValidation do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  use ExStructable, use_ex_constructor_library: [
    # args for ExConstructor here
  ]
end
```
