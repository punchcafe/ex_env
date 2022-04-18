
Application.put_env(:some_app, SomeKey, "some_var")
Zapp.put(SomeModule, :some_key, "some_var")

large_atom_key_value_set = 0..500 |> Enum.map(fn number -> {String.to_atom("key_#{number}"), number} end)

set_app_envs = fn -> large_atom_key_value_set |> Enum.map(fn {key, val} -> Application.put_env(LargeStringSet, key, val) end) end 
set_zapp_envs = fn -> large_atom_key_value_set |> Enum.map(fn {key, val} -> Zapp.put(LargeStringSet, key, val) end) end 

run_app = fn -> large_atom_key_value_set |> Enum.map(fn {key, v} -> {:ok, ^v} = Application.fetch_env(LargeStringSet, key) end) end
run_zapp = fn -> large_atom_key_value_set |> Enum.map(fn {key, v} -> ^v =  Zapp.LargeStringSet.env(key) end) end

run_server = fn -> large_atom_key_value_set |> Enum.reduce(%{}, fn {k, v}, acc ->
   new_state = Map.put(acc, k, v) 
   Zapp.Server.handle_call({:put, TestLarge, {k, v}}, nil, acc)
   new_state
  end) end

#set_app_envs.()
#set_zapp_envs.()

deff = quote do
  defmodule Hello do
    def hi(), do: "hi"
  end
end

compile = fn -> 0..500 |> Enum.map(fn _ -> Code.compile_quoted(deff) end) end
map_build = fn -> 
  map = 0..500 |> Enum.reduce(%{}, fn num, acc -> Map.put(acc, "#{num}", num) end)
  Zapp.put(Hi, map) 
end

#TODO: consider parrallelising Zapp calls with a macro which collects and fires off as tasks
Benchee.run(
  %{
    #"compile_quoted" => compile
    #"map_build" => map_build
    "run_server" => run_server,
    # ^ interesting to note that this handle call function is super fast, comparatively
    "set_zapp_envs" => set_zapp_envs
  }
)
"""
Benchee.run(
  %{
    "set_zapp_envs" => set_zapp_envs,
    "set_app_envs" => set_app_envs,
    "application" => fn -> Application.fetch_env(:some_app, SomeKey) end,
    "Zapp" => fn -> Zapp.SomeModule.env(:some_key) end,
    "Large Zapp" => run_zapp,
    "Large App" => run_app
  }
)
"""

"""
Name                  ips        average  deviation         median         99th %
Zapp              89.56 M       11.17 ns   ±156.93%          11 ns          30 ns
application        5.08 M      196.93 ns    ±83.48%         190 ns         490 ns
Large Zapp       0.0420 M    23820.79 ns    ±39.18%       23000 ns       56000 ns
Large App       0.00057 M  1762716.75 ns     ±9.39%     1738000 ns  2419080.00 ns
"""