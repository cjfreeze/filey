defmodule Filey.MixProject do
  use Mix.Project

  def project do
    [
      app: :filey,
      version: "0.2.3",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: """
      Remote file storage bootstrap library with dev conveniences
      """
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Filey.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.5"},
      {:gcs, "~> 0.1.0"},
      {:ecto_sql, "~> 3.5"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:jason, "~> 1.0"},
      {:configparser_ex, "~> 4.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: [
        "Chris Freeze"
      ],
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      links: %{"GitHub" => "https://github.com/cjfreeze/filey"}
    ]
  end
end
