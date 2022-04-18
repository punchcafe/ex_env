defmodule Zapp do
  @moduledoc """
  A module providing utility functions for setting environment variables with very fast read speeds.
  """
  defguard is_valid(mod, key) when is_atom(mod) and (is_atom(key) or is_binary(key))

  @doc """
  Sets an environment variable for a given module and key.
  """
  @spec put(mod :: atom(), key :: atom() | String.t(), value :: any()) :: :ok | {:error, atom()}
  def put(mod, key, value)

  def put(mod, key, value) when is_valid(mod, key) do
    with :ok <- validate_mod(mod) do
      GenServer.call(Zapp.Server, {:put, mod, {key, value}})
    end
  end

  def put(mod, _, _) when is_atom(mod), do: {:error, :invalid_key}
  def put(_, _, _), do: {:error, :invalid_module}

  @doc """
  Sets a number of environment variables from a map or keyword list under a given module.
  """
  @spec put(mod :: atom(), config :: map() | Keyword.t()) :: :ok | {:error, atom()}
  def put(mod, config)

  def put(mod, config) when is_atom(mod) and (is_map(config) or is_list(config)) do
    with :ok <- validate_mod(mod),
         :ok <- validate_config(config) do
      GenServer.call(Zapp.Server, {:put, mod, config})
    end
  end

  def put(mod, _) when is_atom(mod), do: {:error, :invalid_config}
  def put(_, _), do: {:error, :invalid_module}

  @doc """
  Raises exception on failure of `put/3`.
  """
  @spec put!(mod :: atom(), key :: atom() | String.t(), value :: any()) :: :ok | {:error, atom()}
  def put!(module, key, value), do: raise_on_error(fn -> put(module, key, value) end)

  @doc """
  Raises exception on failure of `put/2`.
  """
  @spec put!(mod :: atom(), config :: map() | Keyword.t()) :: :ok | no_return()
  def put!(module, config), do: raise_on_error(fn -> put(module, config) end)

  @doc """
  Fetches an environment variable for a given module and key.
  """
  @spec fetch_env(mod :: atom(), key :: atom() | String.t()) :: any()
  def fetch_env(mod, key)

  def fetch_env(mod, key) when is_valid(mod, key) do
    {:ok, Module.concat(Zapp, mod).env(key)}
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

  defp raise_on_error(function) do
    case function.() do
      :ok -> :ok
      {:error, err} -> raise RuntimeError
    end
  end
end
