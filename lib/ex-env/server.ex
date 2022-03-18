defmodule ExEnv.Server do
  use GenServer
  use Application
  alias ExEnv.ModuleOwner

  @dynamic_supervisor_name __MODULE__.DynamicSupervisor
  @registry_name __MODULE__.Registry

  def start(_, _) do
    :ets.new(:ex_env_module_owners_state, [:public, :named_table])
    child_specs = [
      {Registry, [keys: :unique, name: @registry_name]},
      DynamicSupervisor.child_spec(name: @dynamic_supervisor_name, strategy: :one_for_one),
      __MODULE__
    ]
    Supervisor.start_link(child_specs, [strategy: :one_for_one])
  end

  def child_spec(_) do
    %{
        id: __MODULE__,
        start: {GenServer, :start_link, [__MODULE__, [], [name: __MODULE__]]},
        name: __MODULE__,
        type: :worker,
        restart: :permanent
    }
  end

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call(msg = {:put, module, key, value}, _from, _) do
    case Registry.lookup(@registry_name, module) do
      [] ->
        pid =
          DynamicSupervisor.start_child(
            @dynamic_supervisor_name,
            {ModuleOwner, [module, @registry_name]}
          )

          :timer.sleep(50)
        handle_call(msg, nil, nil)

      [{pid, _}] ->
        ModuleOwner.put(pid, key, value)
        {:reply, :ok, nil}
    end
  end
end
