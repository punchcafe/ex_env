defmodule ExEnv.ModuleOwner do
  # TODO: add timeout
  def new(module_name), do: GenServer.start_link(__MODULE__.Server, module_name)

  def put(process, key, value), do: GenServer.call(process, {:put, key, value})
end
