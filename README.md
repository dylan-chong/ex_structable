# ExStructable

[![Build Status](https://travis-ci.org/dylan-chong/ex_structable.svg?branch=master)](https://travis-ci.org/dylan-chong/ex_structable)
[![Coverage Status](https://coveralls.io/repos/github/dylan-chong/ex_structable/badge.svg?branch=master)](https://coveralls.io/github/dylan-chong/ex_structable?branch=master)
[![](https://img.shields.io/hexpm/v/ex_structable.svg?style=flat)](https://hex.pm/packages/ex_structable)

<!-- If this is changed, update mix.exs description/0 -->
Reduce boilerplate by generating struct `new` and `put` functions,
and validate your structs when they are created and updated.
<!-- If this is changed, update mix.exs description/0 -->

Optionally uses [ExConstructor](https://github.com/appcues/exconstructor) to
"make it easier to instantiate struts from external data".

## Installation

The package can be installed by adding `ex_structable` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_structable, "~> 0.3.0"},
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

And you have to write this boilerplate for every module you have! That can be a
lot of boilerplate!

## A Solution

By the magic of Elixir macros, we can remove the boilerplate!

```elixir
defmodule Point do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  use ExStructable # Adds `new` and `put` dynamically

  # Optional hook
  @impl true
  def validate_struct(struct, _options) do
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

And if you don't need validation yet, you might want to still add `new` and
`put` methods to be consistent (or to make it easier to add validation later).
In that case, you can just leave out the `validate_struct/2` implementation.

```elixir
defmodule Point do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, :z]

  use ExStructable # Adds `new` and `put` dynamically
```

## More Info

[For more detailed API documentation, see HexDocs](https://hexdocs.pm/ex_structable/api-reference.html).
