defmodule Client.Order do
  @derive [Poison.Encoder]
  defstruct [:account, :venue, :stock, :price, :qty, :direction, :orderType]
end
