defmodule Vttyl.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/cadebward/vtt"

  def project do
    [
      app: :vtt,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: @repo_url,
      homepage_url: @repo_url,
      name: "Vtt",
      description: "A dead simple vtt parser.",
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        source_url: @repo_url,
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Cade Ward"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @repo_url,
        "Made by Grain" => "https://grain.co"
      }
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.20", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false}
    ]
  end
end
