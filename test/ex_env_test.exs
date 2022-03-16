defmodule ExEnvTest do
  use ExUnit.Case
  doctest ExEnv

  alias ExEnv.ModuleQuoted
  alias ExEnv.ModuleQuoted.Def


  test "EXPERIMENTAL" do
    test_mod = %ModuleQuoted{mod_name: MyEnv, clause_definitions: [%Def{match_atom: :hello, return_value: "world"}]}
    test_mod |> ModuleQuoted.module_quoted() |> Code.compile_quoted()
    assert ExEnv.MyEnv.env(:hello) == "world"
  end
end
