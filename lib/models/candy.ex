defmodule Workshop.Models.Candy do
  @moduledoc """
  Simplifies the use of the `candy` model.
  """

  @spec model(non_neg_integer(), non_neg_integer()) :: any()
  def model(input_height, input_width) do
    Workshop.StyleTransferNet.model(
      modifications: [0, 13, 11, 16, 18, 2],
      large_kernel_size: 7,
      size: {input_height, input_width}
    )
  end

  @spec postprocess(Nx.Tensor.t()) :: Nx.Tensor.t()
  def postprocess(tensor) do
    standard_deviation = Nx.variance(tensor) |> Nx.to_number() |> :math.sqrt()
    scale = 255 / (5.5 * standard_deviation)
    shift_tensor = Nx.broadcast(0.7 * standard_deviation, Nx.shape(tensor))

    tensor
    |> Nx.backend_transfer(EXLA.Backend)
    |> Nx.add(shift_tensor)
    |> Nx.multiply(scale)
    |> Nx.max(0)
    |> Nx.min(255)
    |> Nx.round()
    |> Nx.as_type(:u8)
    |> Nx.to_binary()
  end
end
