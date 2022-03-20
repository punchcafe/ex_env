defmodule ExEnv.Server do
  use GenServer
  alias ExEnv.State

  def start(_, _) do
    Supervisor.start_link([child_spec()], strategy: :one_for_one)
  end

  def child_spec() do
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
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call(msg = {:put, module, key, value}, _from, state) do
    state_entry = state[module] || %State{mod_name: module}
    {:ok, state_entry} = State.put(state_entry, key, value)
    state_entry |> State.module_quoted() |> Code.compile_quoted()
    {:reply, :ok, Map.put(state, module, state_entry)}
  end
end
