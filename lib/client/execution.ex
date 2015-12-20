defmodule Client.Execution do
  @derive [Poison.Encoder]
  defstruct [:ok, :account, :venue, :symbol, :order, :standingId, :incomingId, :price,
    :filled, :filledAt, :standingComplete, :incomingComplete]
end
