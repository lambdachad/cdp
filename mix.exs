defmodule CDP.MixProject do
  use Mix.Project

  def project do
    [
      app: :cdp,
      version: "0.1.0",
      elixir: "~> 1.19",
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

  defp deps do
    [
      {:websockex, "~> 0.5"},
      {:req, "~> 0.5"}
    ]
  end
end
