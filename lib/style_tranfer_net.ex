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

  # def load_params_from_stdin() do
  #   params_keys_mapping = %{
  #     "conv1.conv2d.weight" => ~w(conv_0 kernel),
  #     "conv1.conv2d.bias" => ~w(conv_0 bias),
  #     "conv2.conv2d.weight" => ~w(conv_1 kernel),
  #     "conv2.conv2d.bias" => ~w(conv_1 bias),
  #     "res1.conv1.conv2d.weight" => ~w(conv_2 kernel),
  #     "res1.conv1.conv2d.bias" => ~w(conv_2 bias),
  #     "res2.conv1.conv2d.weight" => ~w(conv_3 kernel),
  #     "res2.conv1.conv2d.bias" => ~w(conv_3 bias),
  #     "res3.conv1.conv2d.weight" => ~w(conv_4 kernel),
  #     "res3.conv1.conv2d.bias" => ~w(conv_4 bias),
  #     "deconv1.conv2d.weight" => ~w(conv_5 kernel),
  #     "deconv1.conv2d.bias" => ~w(conv_5 bias),
  #     "deconv2.conv2d.weight" => ~w(conv_6 kernel),
  #     "deconv2.conv2d.bias" => ~w(conv_6 bias),
  #     "in1.weight" => ~w(instance_norm_0 gamma),
  #     "in1.bias" => ~w(instance_norm_0 beta),
  #     "in2.weight" => ~w(instance_norm_1 gamma),
  #     "in2.bias" => ~w(instance_norm_1 beta),
  #     "res1.in1.weight" => ~w(instance_norm_2 gamma),
  #     "res1.in1.bias" => ~w(instance_norm_2 beta),
  #     "res2.in1.weight" => ~w(instance_norm_3 gamma),
  #     "res2.in1.bias" => ~w(instance_norm_3 beta),
  #     "res3.in1.weight" => ~w(instance_norm_4 gamma),
  #     "res3.in1.bias" => ~w(instance_norm_4 beta),
  #     "in4.weight" => ~w(instance_norm_5 gamma),
  #     "in4.bias" => ~w(instance_norm_5 beta)
  #   }

  #   IO.stream(:line)
  #   |> Stream.chunk_every(2)
  #   |> Enum.map(fn [name, list] ->
  #     name = String.trim(name)
  #     path = Map.fetch!(params_keys_mapping, name)

  #     tensor =
  #       Code.eval_string(list)
  #       |> elem(0)
  #       |> Nx.tensor()
  #       |> Nx.multiply(100)

  #     # |> Nx.add(0.1)

  #     # tensor =
  #     #   tensor
  #     #   |> Nx.multiply(Nx.mean(tensor))

  #     # if Nx.rank(tensor) > 1, do: Nx.transpose(tensor), else: tensor
  #     tensor =
  #       case Nx.rank(tensor) do
  #         1 ->
  #           tensor

  #         4 ->
  #           # orginal
  #           Nx.transpose(tensor, axes: [2, 3, 1, 0])
  #           # Nx.transpose(tensor, axes: [3, 2, 1, 0])
  #       end

  #     {path, tensor}
  #   end)
  #   |> map_from_path_to_value()
  #   |> Map.new(fn {key, value} ->
  #     case value do
  #       %{"beta" => tensor} ->
  #         value =
  #           Map.merge(value, %{
  #             "mean" => Nx.broadcast(0.0, Nx.shape(tensor)),
  #             "var" => Nx.broadcast(1.0, Nx.shape(tensor))
  #           })

  #         {key, value}

  #       value ->
  #         {key, value}
  #     end
  #   end)
  # end

  # defp map_from_path_to_value(path_to_value) do
  #   require Nx

  #   path_to_value
  #   |> Enum.group_by(
  #     fn {[head | _tail], _tensor} -> head end,
  #     fn {[_head | tail], tensor} -> {tail, tensor} end
  #   )
  #   |> Map.new(fn {key, entries_list} ->
  #     case entries_list do
  #       [{[], tensor}] when Nx.is_tensor(tensor) ->
  #         {key, tensor}

  #       entries ->
  #         entries_map = map_from_path_to_value(entries)
  #         {key, entries_map}
  #     end
  #   end)
  # end

  # def inspect_params(params, label) do
  #   params
  #   |> transform_params()
  #   |> IO.inspect(label: label)
  # end

  # defp transform_params(tensor) when Nx.is_tensor(tensor) do
  #   Nx.shape(tensor)
  # end

  # defp transform_params(map) when is_map(map) do
  #   Map.new(map, fn {key, value} -> {key, transform_params(value)} end)
  # end

  # def debug(x) do
  #   Axon.layer(&debug_impl/2, [x])
  # end

  # defp debug_impl(x, _opts \\ []) do
  #   IO.inspect({x.shape, x}, label: "ELIXIR DEBUG")
  #   x
  # end
end
