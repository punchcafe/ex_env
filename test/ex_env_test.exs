defmodule ExEnvTest do
  use ExUnit.Case
  doctest ExEnv

  alias ExEnv.ModuleOwner

  test "EXPERIMENTAL" do
    test_mod = %ModuleOwner{mod_name: MyEnv, config_map: %{hello: "world"}}
    test_mod |> ModuleOwner.module_quoted() |> Code.compile_quoted()
    assert ExEnv.MyEnv.env(:hello) == "world"
  end
end
