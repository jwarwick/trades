defmodule Client.Execution do
  @derive [Poison.Encoder]
  defstruct [:ok, :account, :venue, :symbol, :order, :standingId, :incomingId, :price,
    :filled, :filledAt, :standingComplete, :incomingComplete]

  # @doc """
  # Decode the `fills` subcomponent of the order result
  # """
  # def decode_fills(fills) do
  #   Enum.map(fills, &(struct(Client.Fill, &1)))
  # end

  # def update_fills(order_result) do
  #   %Client.OrderResult{order_result | fills: decode_fills(order_result.fills)}
  # end
end
