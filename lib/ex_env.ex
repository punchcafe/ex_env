defmodule ExEnv do
  # TODO: implement gen server with registry 

  #def put(mod, key, value), do: GenServer.call(ExEnv.Server, {:put, mod, key, value})
  def put(mod, key, value), do: GenServer.call(ExEnv.SimpleServer, {:put, mod, key, value})
end
