
Application.put_env(:some_app, SomeKey, "some_var")
Zapp.put(SomeModule, :some_key, "some_var")

Benchee.run(
  %{
    "application" => fn -> Application.fetch_env(:some_app, SomeKey) end,
    "Zapp" => fn -> Zapp.SomeModule.env(:some_key) end
  }
)

"""
Name                  ips        average  deviation         median         99th %
Zapp             94.56 M       10.58 ns   ±108.36%          10 ns          29 ns
application        5.32 M      188.03 ns    ±50.98%         180 ns         430 ns

Comparison: 
Zapp             94.56 M
application        5.32 M - 17.78x slower +177.45 ns
"""