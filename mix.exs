defmodule Downloadex.MixProject do
  use Mix.Project

  def project do
    [
      app: :downloadex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/avinayak/pinbacker"
    ]
  end

  defp description do
    """
    An Elixir library to download large amounts of file in parallel.
    """
  end

  defp package do
    [
      name: "downloadex",
      licenses: ["MIT"],
      contributors: ["Atul Vinayak"],
      links: %{"GitHub" => "https://github.com/avinayak/downloadex"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Downloadex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
