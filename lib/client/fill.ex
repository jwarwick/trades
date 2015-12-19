defmodule Client.Fill do
  @derive [Poison.Encoder]
  defstruct [:price, :qty, :ts]
end
