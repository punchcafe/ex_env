defmodule Zapp.Server do
  @moduledoc false

  ## Private module for internal use

  use GenServer
  alias Zapp.ModuleState, as: State

  @impl Application
  def start(_, _) do
    Supervisor.start_link([child_spec()], strategy: :one_for_one)
  end

  defp child_spec() do
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
  def handle_call({:put, module, input}, _from, state) do
    state_entry = state[module] || %State{mod_name: module}

    {:ok, state_entry} =
      case input do
        {k, v} -> State.put(state_entry, k, v)
        map = %{} -> State.put(state_entry, map)
        list when is_list(list) -> State.put(state_entry, list)
      end

    Code.put_compiler_option(:ignore_module_conflict, true)
    state_entry |> State.module_quoted() |> Code.compile_quoted()
    Code.put_compiler_option(:ignore_module_conflict, false)
    {:reply, :ok, Map.put(state, module, state_entry)}
  end
end
