defmodule ChockABlock do
  @moduledoc """
  GenServer to implement a strategy to buy a large block of a single stock.
  """

  use GenServer

  @api_key "cbfb31ca0bd485da4e54ca12fd287a0f8cf7a234"
  @account "TB56474231"
  @venue "EPSBEX"
  @stock "FAR"
  @quantity 100_000
  @block_size 5_000
  @delay_ms 20

  defmodule State do
    defstruct [:remaining_qty, :executed, order_id: nil, target_price: 50_000]
  end

  ##
  ## Interface

  @doc """
  Launch the strategy
  """
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  @doc """
  Last trade info
  """
  def last, do: last_trade

  @doc """
  Order book info
  """
  def book do
    Client.order_book(@venue, @stock)
  end

  @doc """
  Set the client target price
  """
  def set_target(pid, price) do
    GenServer.cast(pid, {:target_price, price})
  end

  ##
  ## Callbacks

  @doc """
  Initialize the strategy
  """
  def init(_args) do
    {:ok, %State{remaining_qty: @quantity, executed: []}, 0}
  end

  def handle_cast({:target_price, price}, state) do
    {:noreply, %State{state | target_price: price}}
  end

  def handle_info(:timeout, state = %State{remaining_qty: remaining_qty}) when remaining_qty <= 0 do
    IO.inspect "Finished: #{state.executed}"
    {:stop, :normal, state}
  end
  def handle_info(:timeout, state = %State{order_id: nil}) do
    # no active order
    {:ok, last} = last_trade
    # IO.puts "Last: #{last.lastSize}@#{last.last}"
    {:ok, result} = buy(block_size(state), bid_price(last.last, state))
    {:noreply, %State{state | order_id: result.id}, @delay_ms}
  end
  def handle_info(:timeout, state = %State{order_id: id}) do
    {:ok, result} = order_status(id)
    if result.open do
      {:noreply, state, @delay_ms}
    else
      remaining = remaining_qty(state, result.totalFilled)
      # IO.puts "Filled: #{result.totalFilled}, Remaining: #{remaining}"
      {:noreply, %State{state | remaining_qty: remaining, order_id: nil}, @delay_ms}
    end
  end

  ##
  ## Helpers

  defp last_trade do
    {:ok, q} = Client.quote(@venue, @stock)
    {:ok, %{last: q.last, lastSize: q.lastSize}}
  end

  defp order_status(id) do
    Client.order_status(id, @venue, @stock, @api_key)
  end

  defp buy(qty, price) do
    # IO.puts "Buying #{qty} @ #{price}"
    Client.buy(@account, @venue, @stock, price, qty, :ioc, @api_key)
  end

  defp remaining_qty(%State{remaining_qty: remaining}, nil), do: remaining
  defp remaining_qty(%State{remaining_qty: remaining}, filled), do: remaining - filled

  defp block_size(%State{remaining_qty: r}) when @block_size > r, do: r
  defp block_size(_state), do: @block_size

  defp bid_price(last_bid, %State{target_price: p}) when last_bid > p, do: p
  defp bid_price(last_bid, _state), do: last_bid

end
