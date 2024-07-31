defmodule Workshop.StyleTransferNet do
  @moduledoc false
  require Nx

  def model(options \\ []) do
    %{
      large_kernel_size: large_kernel_size,
      inner_channels: inner_channels,
      modifications: [mod_0, mod_1, mod_2, mod_3, mod_4, mod_5],
      size: size
    } =
      Keyword.validate!(options,
        large_kernel_size: 9,
        inner_channels: 24,
        modifications: [0, 0, 0, 0, 0, 0],
        size: {1280, 1280}
      )
      |> Map.new()

    {height, width} =
      case size do
        {height, width} -> {height, width}
        size -> {size, size}
      end

    Axon.input("data")
    |> padded_conv(
      out_channels: div(inner_channels, 2) - mod_0,
      kernel_size: large_kernel_size,
      strides: 2
    )
    |> Axon.instance_norm()
    |> Axon.leaky_relu()
    |> padded_conv(
      out_channels: inner_channels - mod_1,
      kernel_size: 3,
      strides: 2
    )
    |> Axon.instance_norm()
    |> Axon.leaky_relu()
    |> latent_layer(out_channels: inner_channels - mod_2)
    |> latent_layer(out_channels: inner_channels - mod_3)
    |> latent_layer(out_channels: inner_channels - mod_4)
    |> upsample_conv_layer(
      out_channels: div(inner_channels, 2) - mod_5,
      kernel_size: 3,
      strides: 1,
      resize_target_size: {div(height, 2), div(width, 2)}
    )
    |> Axon.instance_norm()
    |> Axon.leaky_relu()
    |> upsample_conv_layer(
      out_channels: 3,
      kernel_size: large_kernel_size,
      strides: 1,
      resize_target_size: {height, width}
    )
  end

  defp padded_conv(x,
         out_channels: out_channels,
         kernel_size: kernel_size,
         strides: strides
       ) do
    x
    |> Axon.conv(out_channels,
      kernel_size: kernel_size,
      strides: strides,
      padding: :same
    )
  end

  defp latent_layer(x,
         out_channels: out_channels
       ) do
    kernel_size = 3
    strides = 1

    x
    |> padded_conv(
      out_channels: out_channels,
      kernel_size: kernel_size,
      strides: strides
    )
    |> Axon.instance_norm()
    |> Axon.hard_silu()
  end

  defp upsample_conv_layer(x,
         out_channels: out_channels,
         kernel_size: kernel_size,
         strides: strides,
         resize_target_size: resize_target_size
       ) do
    x
    |> Axon.resize(resize_target_size)
    |> Axon.conv(out_channels,
      kernel_size: kernel_size,
      strides: strides,
      padding: :same
    )
  end
end
