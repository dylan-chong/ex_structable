defmodule TestModules do
  def test_modules do
    [
      "without ExConstructor": {NoStrictKeys},
      "with ExConstructor": {NoStrictKeysExConstructor},
    ]
  end
end

defmodule NoStrictKeys do
  @enforce_keys [:a]
  defstruct [:a]
  use ExStructable, strict_keys: false
end

defmodule NoStrictKeysExConstructor do
#   @enforce_keys [:a] # TODO Put back once the library is fixed
  defstruct [:a]
  use ExStructable, use_ex_constructor_library: true, strict_keys: false
end

defmodule ExStructableNoStrictKeysTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  describe "with strict_keys: false" do
    test_with_params "new still creates",
    fn module ->
      expected = Kernel.struct!(module, [a: 1])
      assert expected == module.new(a: 1)
    end, do: TestModules.test_modules()

    test_with_params "put still updates data successfully",
    fn module ->
      expected = Kernel.struct!(module, [a: 2])
      assert expected == [a: 1] |> module.new() |> module.put(a: 2)
    end, do: TestModules.test_modules()

    test_with_params "new ignores invalid keys",
    fn module ->
      expected = Kernel.struct!(module, [a: 1])
      assert expected == module.new(a: 1, invalid_key: 2)
    end, do: TestModules.test_modules()

    test_with_params "put ignores invalid keys",
    fn module ->
      expected = Kernel.struct!(module, [a: 1])
      assert expected == module.put(
        module.new(a: 1),
        invalid_key: 2
      )
    end, do: TestModules.test_modules()

    test_with_params "new does not check for enforced keys",
    fn module ->
      expected = Kernel.struct!(module, [a: nil])
      assert expected == module.new([])
    end, do: TestModules.test_modules()
  end
end
