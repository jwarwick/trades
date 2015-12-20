defmodule PositionAgent do
  @moduledoc """
  Agent that stores account value and number of shares
  """

  defmodule State do
    defstruct venue: nil, symbol: nil, quantity: 0, cash: 0
  end

  def start_link(venue, symbol) do
    Agent.start_link(fn -> %State{venue: venue, symbol: symbol} end)
  end

  def position(pid) do
    Agent.get(pid, &(&1))
  end

  def nav(pid, price) do
    state = position(pid)
    nav = state.cash + (state.quantity * price)
    %{price: price, nav: nav, state: state}
  end

  def buy(pid, %{qty: qty, price: price}) do
    Agent.get_and_update(pid, fn s -> buy_update(s, qty, price) end)
  end

  def sell(pid, %{qty: qty, price: price}) do
    Agent.get_and_update(pid, fn s -> sell_update(s, qty, price) end)
  end

  ##
  ## Helpers

  defp buy_update(state, qty, price) do
    new_state = %State{state | quantity: state.quantity + qty, cash: state.cash - (qty * price)}
    {new_state, new_state}
  end

  defp sell_update(state, qty, price) do
    new_state = %State{state | quantity: state.quantity - qty, cash: state.cash + (qty * price)}
    {new_state, new_state}
  end

end
