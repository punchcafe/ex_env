defmodule ExEnv.ModuleOwner.Server do
  alias ExEnv.ModuleOwner.State

  use GenServer

  @state_table :ex_env_module_owners_state

  @impl GenServer
  def init(module_name) do
    send(self(), :change)

    case :ets.lookup(@state_table, module_name) do
      [] -> {:ok, %State{mod_name: module_name}}
      [{_, existing_state = %State{}}] -> {:ok, existing_state}
    end
  end

  @impl GenServer
  def terminate(_, state = %State{mod_name: name}) do
    :ets.insert(@state_table, {name, state})
  end

  def state_table_name, do: @state_table

  @impl GenServer
  def handle_info(:change, state) do
    state |> State.module_quoted() |> Code.compile_quoted()
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:put, key, value}, _from, state) do
    with {:ok, state} <- State.put(state, key, value) do
      send(self(), :change)
      # TODO: consider the potential for a build up of change requests?
      {:reply, :ok, state}
    end
  end
end
