defmodule ExEnv.ModuleOwner do
  # TODO: add timeout
  def start_link(module_name, registry) do
    GenServer.start_link(__MODULE__.Server, module_name, [
      name: {:via, Registry, {registry, module_name}}]
    )
  end

  def child_spec([module, registry]) do
    %{
        id: Module.concat(module, Owner),
        start: {__MODULE__, :start_link, [module, registry]},
        type: :worker,
        restart: :permanent
    }
  end

  def put(process, key, value), do: GenServer.call(process, {:put, key, value})
end
