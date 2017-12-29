defmodule ExStructableTest do
  use ExUnit.Case
  doctest ExStructable

  defmodule ABCStruct do
    @enforce_keys [:a]
    defstruct [:a, b: [2], c: 3]
    use ExStructable
  end

  defmodule DEStruct do
    defstruct [:d, :e]
    use ExStructable
  end

  defmodule FStruct do
    defstruct [:f]
    use ExStructable

    def validate_struct(struct = %FStruct{f: f}, _) do
      if f < 0 do
        raise ArgumentError, "invalid param"
      end

      struct
    end
  end

  defmodule GStruct do
    defstruct [:g]
    use ExStructable

    def validate_struct(_, _), do: nil
  end

  defmodule HStruct do
    defstruct [:h]
    use ExStructable

    def validate_struct(struct, _) do
      if struct.h < 0, do: raise ArgumentError, "Invalid struct"
      struct
    end

    def after_new(_, _) do
      raise RuntimeError, "after_new called"
    end

    def after_put(_, _) do
      raise RuntimeError, "after_put called"
    end
  end

  defmodule IStruct do
    defstruct [:the_field]
    use ExStructable, use_ex_constructor_library: true
  end

  defmodule JStruct do
    defstruct [:the_field]
    use ExStructable, use_ex_constructor_library: [
      camelcase: false
    ]
  end

  defmodule KStruct do
    defstruct [:k, :l]
    use ExStructable

    def validate_struct(struct = %KStruct{k: k}, _) do
      if k < 0 do
        raise ArgumentError, "invalid param"
      end

      struct
    end
  end

  defmodule Point do
    defstruct [:x, :y, :z]

    use ExStructable, use_ex_constructor_library: true

    def validate_struct(struct, _) do
      if struct.x < 0 or struct.y < 0 or struct.z < 0 do
        raise ArgumentError
      end

      struct
    end
  end

  # @enforce_keys [:x, :y]
  # TODO use and make PointWithEnforce when ExConstructor fix their library

  describe "new creates" do
    test "with all params" do
      expected = %ABCStruct{a: 1, b: 2, c: {4, 5}}
      assert ABCStruct.new(a: 1, b: 2, c: {4, 5}) == expected
    end

    test "with all non-default params" do
      expected = %ABCStruct{a: 1, b: 2, c: 3}
      assert ABCStruct.new(a: 1, b: 2) == expected
    end
  end

  describe "when required param is not passed" do
    test "new fails with default options" do
      assert_raise(
        ArgumentError,
        ~r".*:a.*",
        fn -> ABCStruct.new([]) end
      )
    end
  end

  describe "when passing an invalid parameter" do
    test "new fails with default options" do
      assert_raise(
        KeyError,
        fn -> ABCStruct.new([a: 1, invalid: 2]) end
      )
    end
  end

  describe "when validate_struct is overriden" do
    test "new creates with valid params" do
      assert FStruct.new(f: 1) == %FStruct{f: 1}
    end

    test "new fails with invalid param" do
      assert_raise(
        ArgumentError,
        "invalid param",
        fn -> FStruct.new(f: -1) end
      )
    end

    test "new creates with invalid param and validate_struct: false" do
      assert FStruct.new([f: -1], [validate_struct: false]) == %FStruct{f: -1}
    end

    test "fails if returns nil" do
      assert_raise(
        ExStructable.InvalidHookError,
        ~r"validate_struct cannot return nil.*",
        fn -> GStruct.new(g: -1) end
      )
    end

    test "puts data with invalid param and validate_struct: false" do
      expected = %FStruct{f: -1}
      assert expected == FStruct.put(%FStruct{f: 2}, [f: -1], [
        validate_struct: false,
      ])
    end

    test "put fails with invalid data" do
      assert_raise(
        ArgumentError,
        "invalid param",
        fn -> FStruct.put(%FStruct{f: 1}, [f: -1]) end
      )
    end
  end

  describe "put" do
    test "fails with non-struct" do
      assert_raise(
        FunctionClauseError,
        fn -> FStruct.put(:not_a_struct, [f: 1]) end
      )
    end

    test "fails with wrong type of struct" do
      assert_raise(
        ArgumentError,
        fn -> FStruct.put(%GStruct{g: 2}, [g: 1]) end
      )
    end

    test "updates data successfully" do
      expected = %KStruct{k: 1, l: 2}
      assert expected == KStruct.put(%KStruct{k: 2, l: 2}, [k: 1])
    end

    test "fails with invalid key" do
      f = %FStruct{f: 2}
      assert_raise(
        KeyError,
        fn -> FStruct.put(f, [invalid_key: 1]) end
      )
    end
  end

  describe "after_new" do
    test "is called after new" do
      assert_raise(
        RuntimeError,
        "after_new called",
        fn -> HStruct.new(h: 1) end
      )
    end

    test "is notcalled after failed new" do
      assert_raise(
        ArgumentError,
        fn -> HStruct.new(h: -1) end
      )
    end
  end

  describe "after_put" do
    test "is called after put" do
      assert_raise(
        RuntimeError,
        "after_put called",
        fn -> HStruct.put(%HStruct{h: 1}, [h: 2]) end
      )
    end

    test "is not called after failed put" do
      assert_raise(
        ArgumentError,
        fn -> HStruct.put(%HStruct{h: 1}, [h: -1]) end
      )
    end
  end

  describe "__using__ ExConstructor" do
    test "new creates from Keyword List" do
      expected = %Point{x: 1, y: 2, z: nil}
      assert expected == Point.new(x: 1, y: 2)
    end

    test "new creates from Map" do
      expected = %Point{x: 1, y: 2, z: nil}
      assert expected == Point.new(%{x: 1, y: 2})
    end

    test "put adds from Map" do
      expected = %Point{x: 3, y: 2, z: nil}
      result =
        %{x: 1, y: 2}
        |> Point.new()
        |> Point.put(%{x: 3})
      assert expected == result
    end

    test "new creates with camel case field with ex_constructor" do
      expected = %IStruct{the_field: 1}
      assert expected == IStruct.new(theField: 1)
    end

    test "new does not create with camel case without ex_constructor option" do
      expected = %JStruct{the_field: nil}
      assert expected == JStruct.new(theField: 1)
    end

    # TODO put with camel case
  end

end
