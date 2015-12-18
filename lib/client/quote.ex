defmodule Client.Quote do
  @derive [Poison.Encoder]
  defstruct [:ok, :symbol, :venue, :bid, :ask, :bidSize, :askSize, :bidDepth, :askDepth,
    :last, :lastSize, :lastTrade, :quoteTime]
end
