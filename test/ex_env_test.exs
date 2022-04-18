defmodule ExEnvTest do
  use ExUnit.Case, async: false
  doctest ExEnv

  alias ExEnv.ModuleOwner

  describe "ExEnv.put/3" do
    test "can create a module" do
      ExEnv.put(TestModuleOne, :hello, "world")
      assert ExEnv.TestModuleOne.env(:hello) == "world"
    end

    test "can overwrite an environment variable" do
      ExEnv.put(TestModuleTwo, :hello, "world")
      ExEnv.put(TestModuleTwo, :hello, "again!")
      assert ExEnv.TestModuleTwo.env(:hello) == "again!"
    end

    test "cannot use invalid module names" do
      assert ExEnv.put(:hello, :hello, "world") == {:error, :invalid_module}
    end

    test "cannot use invalid key types names" do
      assert ExEnv.put(:hello, 123, "world") == {:error, :invalid_key}
    end

    test "can define multiple env vars for one module" do
      ExEnv.put(TestModuleThree, :hello, "world")
      ExEnv.put(TestModuleThree, :good_to_see_you, "again!")

      assert ExEnv.TestModuleThree.env(:hello) == "world"
      assert ExEnv.TestModuleThree.env(:good_to_see_you) == "again!"
    end

    test "can define multiple env vars for multiple modules" do
      ExEnv.put(TestModuleFour, :four, "four")
      ExEnv.put(TestModuleFour, :four_one, "four_one!")
      ExEnv.put(TestModuleFive, :five, "five")
      ExEnv.put(TestModuleFive, :five_one, "five_one!")

      assert ExEnv.TestModuleFour.env(:four) == "four"
      assert ExEnv.TestModuleFour.env(:four_one) == "four_one!"
      assert ExEnv.TestModuleFive.env(:five) == "five"
      assert ExEnv.TestModuleFive.env(:five_one) == "five_one!"
    end

    test "unknown key / value returns nil" do
      ExEnv.put(UnknownKeyWordMod, :hello, "world")

      assert ExEnv.UnknownKeyWordMod.env(:bello) == nil
    end

    test "can store a map in ExEnv" do
      map = %{"hello" => "world"}
      ExEnv.put(MapVariable, :my_map, map)

      assert ExEnv.MapVariable.env(:my_map) == map
    end
  end

  describe "ExEnv.put!/3" do
    test "can create a module" do
      ExEnv.put!(TestModuleBangOne, :hello, "world")
      assert ExEnv.TestModuleBangOne.env(:hello) == "world"
    end

    test "invalid inputs raises errors" do
      assert_raise RuntimeError, fn -> ExEnv.put!(:hello, :hello, "world") end
      assert_raise RuntimeError, fn -> ExEnv.put!(:hello, 123, "world") end
    end
  end

  describe "ExEnv.put/2" do
    test "can configure module by passing map" do
      ExEnv.put(MapTestingConfigMod, %{hello: "world", this_is: "a map"})
      assert ExEnv.MapTestingConfigMod.env(:hello) == "world"
      assert ExEnv.MapTestingConfigMod.env(:this_is) == "a map"
    end

    test "can configure module by passing a keyword list" do
      ExEnv.put(KeywordListTestingConfigMod, hello: "world", this_is: "a list")
      assert ExEnv.KeywordListTestingConfigMod.env(:hello) == "world"
      assert ExEnv.KeywordListTestingConfigMod.env(:this_is) == "a list"
    end

    test "configuring with a keyword list overwrites existing config" do
      ExEnv.put(KeywordListExistingTestingConfigMod, good: "bye", this_is: "a list")
      assert ExEnv.KeywordListExistingTestingConfigMod.env(:good) == "bye"
      ExEnv.put(KeywordListExistingTestingConfigMod, hello: "world", this_is: "a list")
      assert ExEnv.KeywordListExistingTestingConfigMod.env(:good) == nil
    end

    test "configuring with a map overwrites existing config" do
      ExEnv.put(MapExistingTestingConfigMod, %{good: "bye", this_is: "a list"})
      assert ExEnv.MapExistingTestingConfigMod.env(:good) == "bye"
      ExEnv.put(MapExistingTestingConfigMod, %{hello: "world", this_is: "a list"})
      assert ExEnv.MapExistingTestingConfigMod.env(:good) == nil
    end

    test "fails configuration if passed non-keyword list" do
      assert {:error, :invalid_config_entry} == ExEnv.put(ListTestingConfig, [1, 2, 3])
    end

    test "fails configuration if passed map with illegal keys" do
      assert {:error, :invalid_config_entry} == ExEnv.put(IllegalMap, %{1 => "hello"})
    end

    test "fails configuration if passed nil config" do
      assert {:error, :invalid_config} == ExEnv.put(IllegalMap, nil)
    end
  end


  describe "ExEnv.put!/2" do
    test "can configure module by passing map or keyword list" do
      ExEnv.put(MapTestingConfigMod, %{hello: "world", this_is: "a map"})
      ExEnv.put(KeywordListTestingConfigMod, hello: "world", this_is: "a list")
      assert ExEnv.KeywordListTestingConfigMod.env(:hello) == "world"
      assert ExEnv.KeywordListTestingConfigMod.env(:this_is) == "a list"
      assert ExEnv.MapTestingConfigMod.env(:hello) == "world"
      assert ExEnv.MapTestingConfigMod.env(:this_is) == "a map"
    end

    test "raises error on failure" do
      assert_raise RuntimeError, fn -> ExEnv.put!(ListTestingConfig, [1, 2, 3]) end
    end
  end

  describe "ExEnv.fetch_env/3" do
    test "can retrieve config" do
      ExEnv.put(FetchEnvTestModuleOne, :hello, "world")
      ExEnv.put(FetchEnvTestModuleOne, "hello", :world)
      assert ExEnv.fetch_env(FetchEnvTestModuleOne, :hello) == {:ok, "world"}
      assert ExEnv.fetch_env(FetchEnvTestModuleOne, "hello") == {:ok, :world}
    end

    test "illegal module name return nil" do
      assert ExEnv.fetch_env(:hello, :hello) == {:ok, nil}
    end

    test "invalid module type returns error" do
      assert ExEnv.fetch_env("hello", :hello) == {:error, :invalid_module}
    end

    test "invalid key type returns error" do
      assert ExEnv.fetch_env(Hello, 123) == {:error, :invalid_key}
    end

    test "unknown module returns nil" do
      assert ExEnv.fetch_env(UnknownFetchEnvTestModule, :hello) == {:ok, nil}
    end

    test "unknown key returns nil" do
      ExEnv.put(FetchEnvTestModuleTwo, :hello, "world")
      assert ExEnv.fetch_env(FetchEnvTestModuleTwo, :abcd) == {:ok, nil}
    end
  end
end
