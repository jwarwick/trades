defmodule Client.OrderResult do
  @derive [Poison.Encoder]
  defstruct [:ok, :symbol, :venue, :direction, :originalQty, :qty, :price, :orderType,
    :id, :account, :ts, :fills, :totalFilled, :open]

  @doc """
  Decode the `fills` subcomponent of the order result
  """
  def decode_fills(fills) do
    Enum.map(fills, &(struct(Client.Fill, &1)))
  end

  def update_fills(order_result) do
    %Client.OrderResult{order_result | fills: decode_fills(order_result.fills)}
  end
end
