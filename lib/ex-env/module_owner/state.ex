defmodule ExEnv.ModuleOwner.State do
  defstruct config_map: %{}, mod_name: nil

  # add custom guard clause for making sure only valid types passed to add definition

  def put(module_owner = %__MODULE__{config_map: map}, key, value) do
    # TODO: add emit warning, potentially have option to raise on existing/different method
    {:ok, %__MODULE__{module_owner | config_map: Map.put(map, key, value)}}
  end

  def module_quoted(state = %__MODULE__{mod_name: name}) do
    body = render_body(state)

    quote do
      defmodule unquote(Module.concat(ExEnv, name)) do
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
      def env(unquote(k)), do: unquote(v)
    end
  end
end
