defmodule Level.FirstSteps do
  @moduledoc """
  Buy 100 shares of the specified stock
  """

  @doc """
  Launch the level, buy 100 shares at market
  """
  def execute do
    {:ok, start_data} = GameMaster.start_level(:first_steps)
    Apex.ap start_data, numbers: false
    stock = GameMaster.make_stock_id(start_data)
    {:ok, buy_data} = Client.buy(stock, %{qty: 100, price: 100000, order_type: :limit})
    Apex.ap buy_data, numbers: false
    start_data |> GameMaster.instance_id |> GameMaster.status
    {:ok, GameMaster.instance_id(start_data)}
  end
end
