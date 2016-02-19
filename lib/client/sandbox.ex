defmodule Client.Sandbox do
  @moduledoc """
  Sandbox environment provided by StockFighter.

  Provides an venue, stock, and account to play with.
  """

  @doc """
  Sandbox venue.
  """
  def venue, do: "TESTEX"

  @doc """
  Sandbox stock.
  """
  def stock, do: "FOOBAR"

  @doc """
  Sandbox account.
  """
  def account, do: "EXB123456"

  @doc """
  Pre-packaged StockId struct
  """
  def stock_id, do: %Client.StockId{venue: venue(), stock: stock(), account: account()}
end
