
Application.put_env(:some_app, SomeKey, "some_var")
Zapp.put(SomeModule, :some_key, "some_var")

large_string_key_value_set = 0..500 |> Enum.map(fn number -> {"key_#{number}", number} end)

large_string_key_value_set
|> Enum.map(fn {key, val} -> 
  Application.put_env(LargeStringSet, key, val)
  Zapp.put(LargeStringSet, key, val) end)

run_app = fn -> large_string_key_value_set |> Enum.map(fn {key, v} -> {:ok, ^v} = Application.fetch_env(LargeStringSet, key) end) end
run_zapp = fn -> large_string_key_value_set |> Enum.map(fn {key, v} -> ^v =  Zapp.LargeStringSet.env(key) end) end

Benchee.run(
  %{
    "application" => fn -> Application.fetch_env(:some_app, SomeKey) end,
    "Zapp" => fn -> Zapp.SomeModule.env(:some_key) end,
    "Large Zapp" => run_zapp,
    "Large App" => run_app
  }
)

"""
Name                  ips        average  deviation         median         99th %
Zapp              89.56 M       11.17 ns   ±156.93%          11 ns          30 ns
application        5.08 M      196.93 ns    ±83.48%         190 ns         490 ns
Large Zapp       0.0420 M    23820.79 ns    ±39.18%       23000 ns       56000 ns
Large App       0.00057 M  1762716.75 ns     ±9.39%     1738000 ns  2419080.00 ns
"""