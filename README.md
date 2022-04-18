# Zapp

Zapp, a lightning fast application environment configuration library.
Zapplication.
I'll see my self out, thank you very much.

## Performance
- Benchee tests against Application.fetch_env
- Benchee tests against atomic pattern matching v map lookup
## TODOs
- use `Process.register` for module name to enable independent horizontal scalability for individual modules. (consider levvying ETS as previously implemented, and catching Process.register failure for clients)
- `fetch_env!`, `fetch_env` and `get_env` formats
- Batching on put_env to avoid such slow times
- Doc examples
- Pass dialyzer
- Pass credo
- Pass coveralls
- Module.env() tests
- doc specs
- dialyzer
- final test audit
