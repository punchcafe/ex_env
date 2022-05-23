defmodule Zapp.MixProject do
  use Mix.Project

  def project do
    [
      app: :zapp,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc(Mix.env()),
      deps: deps()
    ]
  end

  defp elixirc(env) do
    elixirc_common() ++ elixirc_env(env)
  end

  defp elixirc_env(:dev), do: ["benchee/benchmark_tests.ex"]
  defp elixirc_env(_), do: []
  defp elixirc_common(), do: ["lib/"]

  def application do
    [
      extra_applications: [:logger],
      mod: {Zapp.Server, []}
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
