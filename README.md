# ExEnv
## Performance
- Benchee tests against Application.fetch_env
- Benchee tests against atomic pattern matching v map lookup
## Feature list:
allow map config:
```elixir
ExEnv.put(MyModule, key: value, key2: val2})
```
```elixir
ExEnv.fetch_env(MyModule, :key)
```
