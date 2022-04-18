defmodule ExEnv do
  defguard is_valid(mod, key) when is_atom(mod) and (is_atom(key) or is_binary(key))

  def put(mod, key, value) when is_valid(mod, key) do
    with :ok <- validate_mod(mod) do
      GenServer.call(ExEnv.Server, {:put, mod, {key, value}})
    end
  end

  def put(mod, _, _) when is_atom(mod), do: {:error, :invalid_key}
  def put(_, _, _), do: {:error, :invalid_module}

  def put(mod, config) when is_atom(mod) and (is_map(config) or is_list(config)) do
    with :ok <- validate_mod(mod),
         :ok <- validate_config(config) do
      GenServer.call(ExEnv.Server, {:put, mod, config})
    end
  end

  def put(mod, _) when is_atom(mod), do: {:error, :invalid_config}
  def put(_, _), do: {:error, :invalid_module}


  def fetch_env(mod, key) when is_valid(mod, key) do
    {:ok, Module.concat(ExEnv, mod).env(key)}
  rescue
    UndefinedFunctionError -> {:ok, nil}
  end

  def fetch_env(mod, _) when is_atom(mod), do: {:error, :invalid_key}
  def fetch_env(_, _), do: {:error, :invalid_module}

  defp validate_config(config) when is_list(config) or is_map(config) do
    all_entries_valid? =
      Enum.reduce(config, true, fn entry, bool -> bool && valid_entry?(entry) end)

    if all_entries_valid?, do: :ok, else: {:error, :invalid_config_entry}
  end

  defp validate_config(_), do: {:error, :invalid_config}

  defp validate_mod(mod) do
    case to_string(mod) do
      "Elixir." <> _mod_name -> :ok
      _ -> {:error, :invalid_module}
    end
  end

  defp valid_entry?({key, _}) when is_atom(key) or is_binary(key), do: true
  defp valid_entry?(_), do: false
end
