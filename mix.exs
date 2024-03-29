defmodule Kojin.MixProject do
  use Mix.Project

  def project do
    [
      app: :kojin,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:typed_struct, "~> 0.1.4"},
      {:porcelain, ">= 2.0.3"},
      {:vex, "~> 0.8.0"},
      {:ex_doc, "~> 0.26.0"},
      {:jason, "~> 1.1"},
      {:nimble_parsec, "~> 0.5.0"},
      {:number, "~> 1.0"},
      {:temp, "~> 0.4.7"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:enum_type, "~> 1.1.0"}

      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
