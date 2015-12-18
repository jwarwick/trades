defmodule Client.OrderResult do
  @derive [Poison.Encoder]
  defstruct [:ok, :symbol, :venue, :direction, :originalQty, :qty, :price, :orderType,
    :id, :account, :ts, :fills, :totalFilled, :open]
end
