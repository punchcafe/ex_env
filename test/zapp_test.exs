defmodule ZappTest do
  
  use ExUnit.Case, async: false
  doctest Zapp

  Code.put_compiler_option(:no_warn_undefined, :all)

  describe "Zapp.put/3" do
    test "can create a module" do
      Zapp.put(TestModuleOne, :hello, "world")
      assert Zapp.TestModuleOne.env(:hello) == "world"
    end

    test "can overwrite an environment variable" do
      Zapp.put(TestModuleTwo, :hello, "world")
      Zapp.put(TestModuleTwo, :hello, "again!")
      assert Zapp.TestModuleTwo.env(:hello) == "again!"
    end

    test "cannot use invalid module names" do
      assert Zapp.put(:hello, :hello, "world") == {:error, :invalid_module}
    end

    test "cannot use invalid key types names" do
      assert Zapp.put(:hello, 123, "world") == {:error, :invalid_key}
    end

    test "can define multiple env vars for one module" do
      Zapp.put(TestModuleThree, :hello, "world")
      Zapp.put(TestModuleThree, :good_to_see_you, "again!")

      assert Zapp.TestModuleThree.env(:hello) == "world"
      assert Zapp.TestModuleThree.env(:good_to_see_you) == "again!"
    end

    test "can define multiple env vars for multiple modules" do
      Zapp.put(TestModuleFour, :four, "four")
      Zapp.put(TestModuleFour, :four_one, "four_one!")
      Zapp.put(TestModuleFive, :five, "five")
      Zapp.put(TestModuleFive, :five_one, "five_one!")

      assert Zapp.TestModuleFour.env(:four) == "four"
      assert Zapp.TestModuleFour.env(:four_one) == "four_one!"
      assert Zapp.TestModuleFive.env(:five) == "five"
      assert Zapp.TestModuleFive.env(:five_one) == "five_one!"
    end

    test "unknown key / value returns nil" do
      Zapp.put(UnknownKeyWordMod, :hello, "world")

      assert Zapp.UnknownKeyWordMod.env(:bello) == nil
    end

    test "can store a map in Zapp" do
      map = %{"hello" => "world"}
      Zapp.put(MapVariable, :my_map, map)

      assert Zapp.MapVariable.env(:my_map) == map
    end
  end

  describe "Zapp.put!/3" do
    test "can create a module" do
      Zapp.put!(TestModuleBangOne, :hello, "world")
      assert Zapp.TestModuleBangOne.env(:hello) == "world"
    end

    test "invalid inputs raises errors" do
      assert_raise RuntimeError, fn -> Zapp.put!(:hello, :hello, "world") end
      assert_raise RuntimeError, fn -> Zapp.put!(:hello, 123, "world") end
    end
  end

  describe "Zapp.put/2" do
    test "can configure module by passing map" do
      Zapp.put(MapTestingConfigMod, %{hello: "world", this_is: "a map"})
      assert Zapp.MapTestingConfigMod.env(:hello) == "world"
      assert Zapp.MapTestingConfigMod.env(:this_is) == "a map"
    end

    test "can configure module by passing a keyword list" do
      Zapp.put(KeywordListTestingConfigMod, hello: "world", this_is: "a list")
      assert Zapp.KeywordListTestingConfigMod.env(:hello) == "world"
      assert Zapp.KeywordListTestingConfigMod.env(:this_is) == "a list"
    end

    test "configuring with a keyword list overwrites existing config" do
      Zapp.put(KeywordListExistingTestingConfigMod, good: "bye", this_is: "a list")
      assert Zapp.KeywordListExistingTestingConfigMod.env(:good) == "bye"
      Zapp.put(KeywordListExistingTestingConfigMod, hello: "world", this_is: "a list")
      assert Zapp.KeywordListExistingTestingConfigMod.env(:good) == nil
    end

    test "configuring with a map overwrites existing config" do
      Zapp.put(MapExistingTestingConfigMod, %{good: "bye", this_is: "a list"})
      assert Zapp.MapExistingTestingConfigMod.env(:good) == "bye"
      Zapp.put(MapExistingTestingConfigMod, %{hello: "world", this_is: "a list"})
      assert Zapp.MapExistingTestingConfigMod.env(:good) == nil
    end

    test "fails configuration if passed non-keyword list" do
      assert {:error, :invalid_config_entry} == Zapp.put(ListTestingConfig, [1, 2, 3])
    end

    test "fails configuration if passed map with illegal keys" do
      assert {:error, :invalid_config_entry} == Zapp.put(IllegalMap, %{1 => "hello"})
    end

    test "fails configuration if passed nil config" do
      assert {:error, :invalid_config} == Zapp.put(IllegalMap, nil)
    end
  end

  describe "Zapp.put!/2" do
    test "can configure module by passing map or keyword list" do
      Zapp.put(MapTestingConfigMod, %{hello: "world", this_is: "a map"})
      Zapp.put(KeywordListTestingConfigMod, hello: "world", this_is: "a list")
      assert Zapp.KeywordListTestingConfigMod.env(:hello) == "world"
      assert Zapp.KeywordListTestingConfigMod.env(:this_is) == "a list"
      assert Zapp.MapTestingConfigMod.env(:hello) == "world"
      assert Zapp.MapTestingConfigMod.env(:this_is) == "a map"
    end

    test "raises error on failure" do
      assert_raise RuntimeError, fn -> Zapp.put!(ListTestingConfig, [1, 2, 3]) end
    end
  end

  describe "Zapp.fetch_env/3" do
    test "can retrieve config" do
      Zapp.put(FetchEnvTestModuleOne, :hello, "world")
      Zapp.put(FetchEnvTestModuleOne, "hello", :world)
      assert Zapp.fetch_env(FetchEnvTestModuleOne, :hello) == {:ok, "world"}
      assert Zapp.fetch_env(FetchEnvTestModuleOne, "hello") == {:ok, :world}
    end

    test "illegal module name return nil" do
      assert Zapp.fetch_env(:hello, :hello) == {:ok, nil}
    end

    test "invalid module type returns error" do
      assert Zapp.fetch_env("hello", :hello) == {:error, :invalid_module}
    end

    test "invalid key type returns error" do
      assert Zapp.fetch_env(Hello, 123) == {:error, :invalid_key}
    end

    test "unknown module returns nil" do
      assert Zapp.fetch_env(UnknownFetchEnvTestModule, :hello) == {:ok, nil}
    end

    test "unknown key returns nil" do
      Zapp.put(FetchEnvTestModuleTwo, :hello, "world")
      assert Zapp.fetch_env(FetchEnvTestModuleTwo, :abcd) == {:ok, nil}
    end
  end
end
