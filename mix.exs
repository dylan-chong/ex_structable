defmodule ExConstructorValidator.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_constructor_validator,
      version: "0.1.0",
      elixir: "~> 1.5",
      package: package(),
      description: description(),
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
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
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.11", only: :dev},
      {:excoveralls, "~> 0.8", only: :test},
      {:exconstructor, "~> 1.1.0"},
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Dylan Chong"],
      links: %{"GitHub" => "https://github.com/dylan-chong/ex_constructor_validator"},
    ]
  end

  defp description do
    "Reduces code duplication by adding some boilerplate struct methods"
    <> "to your module."
  end
end
