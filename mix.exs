defmodule Membrane.WorkshopElixirConfUS2024.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/membraneframework-labs/workshop_elixir_conf_us_2024"

  def project do
    [
      app: :workshop_elixir_conf_us_2024,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),

      # hex
      description: "Membrane Workshop for Elixir Conf US 2024",
      package: package(),

      # docs
      name: "Membrane Workshop Elixir Conf US 2024",
      source_url: @github_url,
      docs: docs(),
      homepage_url: "https://membrane.stream"
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:axon, github: "membraneframework-labs/axon"},
      {:membrane_core, "~> 1.1"},
      {:membrane_vpx_plugin, "~> 0.1.1"},
      {:membrane_webrtc_plugin, "~> 0.21.0"},
      {:membrane_h264_ffmpeg_plugin, "~> 0.31.6"},
      {:membrane_h26x_plugin, "~> 0.10.2"},
      {:membrane_mp4_plugin, "~> 0.35.1"},
      {:membrane_file_plugin, "~> 0.17.0"},
      {:membrane_matroska_plugin, "~> 0.6.0"},
      {:membrane_ffmpeg_swscale_plugin, "~> 0.16.1"},
      {:membrane_realtimer_plugin, "~> 0.9.0"},
      {:membrane_opus_plugin, "~> 0.20.2"},
      {:membrane_raw_video_format, "~> 0.4.0", override: true},
      {:membrane_vp8_format, "~> 0.5.0", override: true},
      {:membrane_vp9_format, "~> 0.5.0", override: true},
      {:unifex, "~> 1.2", override: true},
      {:kino, "~> 0.13.1"},
      {:nx, "~> 0.7.0"},
      {:exla, "~> 0.7.0"},
      {:ortex, "~> 0.1.9"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer() do
    opts = [
      flags: [:error_handling]
    ]

    if System.get_env("CI") == "true" do
      # Store PLTs in cacheable directory for CI
      [plt_local_path: "priv/plts", plt_core_path: "priv/plts"] ++ opts
    else
      opts
    end
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membrane.stream"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      formatters: ["html"],
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [Membrane]
    ]
  end
end
