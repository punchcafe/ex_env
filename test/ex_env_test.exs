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

      assert ExEnv.TestModuleFour.env(:bello) == nil
    end
  end
end
