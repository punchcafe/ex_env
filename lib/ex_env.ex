defmodule ExEnv do

  def put(mod, key, value) when is_atom(mod) and is_atom(key) or is_binary(key) do
    GenServer.call(ExEnv.Server, {:put, mod, key, value})
  end

  def fetch_env(mod, key) do
    {:ok, Module.concat(ExEnv, mod).env(key)}
  rescue
    UndefinedFunctionError -> {:ok, nil}
  end
end
