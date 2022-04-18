defmodule Zapp.ModuleState do
  @moduledoc false

  ## Private module for internal use

  defstruct config_map: %{}, mod_name: nil

  def put(module_owner = %__MODULE__{config_map: map}, key, value) do
    {:ok, %__MODULE__{module_owner | config_map: Map.put(map, key, value)}}
  end

  def put(module_owner = %__MODULE__{config_map: map}, keyword) when is_list(keyword) do
    keyword
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, v) end)
    |> then(&put(module_owner, &1))
  end

  def put(module_owner, map) when is_map(map) do
    {:ok, %__MODULE__{module_owner | config_map: map}}
  end

  def module_quoted(state = %__MODULE__{mod_name: name}) do
    body = render_body(state)

    quote do
      defmodule unquote(Module.concat(Zapp, name)) do
        unquote(body)
        def env(_), do: nil
      end
    end
  end

  defp render_body(%__MODULE__{config_map: map, mod_name: name}) when map == %{} do
    quote do
    end
  end

  defp render_body(%__MODULE__{config_map: map, mod_name: name}),
    do: map |> Enum.map(&clause_quoted/1) |> Enum.reduce(&accumulate_quotes/2)

  defp accumulate_quotes(quoted, acc) do
    quote do
      unquote(acc)
      unquote(quoted)
    end
  end

  defp clause_quoted({k, v}) do
    quote do
      def env(unquote(k)), do: unquote(Macro.escape(v))
    end
  end
end
