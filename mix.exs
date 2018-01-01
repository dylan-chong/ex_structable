defmodule ExStructable.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_structable,
      version: "0.2.0",
      elixir: "~> 1.5",
      package: package(),
      description: description(),
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),
      source_url: github_url(),
      homepage_url: github_url(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def github_url, do: "https://github.com/dylan-chong/ex_structable"

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Code deps
      {:exconstructor, "~> 1.1.0"},

      # Project deps
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.11", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8", only: :test, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_parameterized, "~> 1.3.0", only: :test, runtime: false},
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Dylan Chong"],
      links: %{"GitHub" => github_url()},
    ]
  end

  defp description do
    # If this is changed, update README
    "Reduce boilerplate by generating struct `new` and `put` functions. "
    <> "Allows you validate your structs when they are created and updated."
    # If this is changed, update README
  end

  defp aliases do
    [
      check: [
        "test",
        "credo",
        "dialyzer",
      ],
    ]
  end

  defp preferred_cli_env do
    [
      # Aliases
      "check": :test,
      # Coveralls
      "coveralls": :test,
      "coveralls.travis": :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
    ]
  end
end
