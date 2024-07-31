defmodule Workshop.Models.Mosaic do
  @moduledoc """
  Simplifies the use of the `mosaic` model.
  """

  @spec model(non_neg_integer(), non_neg_integer()) :: any()
  def model(input_height, input_width) do
    Workshop.StyleTransferNet.model(
      modifications: [0, 0, 2, 0, 0, 1],
      large_kernel_size: 9,
      size: {input_height, input_width}
    )
  end

  @spec postprocess_rescale(Nx.Tensor.t()) :: Nx.Tensor.t()
  def postprocess_rescale(tensor) do
    standard_deviation = Nx.variance(tensor) |> Nx.to_number() |> :math.sqrt()
    scale = 32.7 / standard_deviation
    shift_tensor = Nx.broadcast(2 * standard_deviation, Nx.shape(tensor))

    tensor
    |> Nx.add(shift_tensor)
    |> Nx.multiply(scale)
    |> Nx.max(0)
    |> Nx.min(255)
  end
end
