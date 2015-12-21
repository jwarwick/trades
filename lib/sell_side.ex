defmodule SellSide do
  @moduledoc """
  Market making strategy
  """

  @api_key "cbfb31ca0bd485da4e54ca12fd287a0f8cf7a234"
  @account "MJ93560781"
  @venue "HCONEX"
  @stock "WSCM"

  defmodule State do
    defstruct [:position_pid, :fill_pid]
  end

  ##
  ## Interface

  @doc """
  Launch the strategy
  """
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def fill_update(pid, args) do
    GenServer.cast(pid, {:fill, args})
  end

  def position(pid) do
    GenServer.call(pid, {:position})
  end

  def nav(pid, price) do
    GenServer.call(pid, {:nav, price})
  end

  ##
  ## Callbacks

  @doc """
  Initialize the strategy
  """
  def init(_args) do
    {:ok, pos_pid} = PositionAgent.start_link(@venue, @stock)
    {:ok, fill_pid} = Client.FillServer.start_link(@account, @venue, @stock, create_callback)
    {:ok, %State{position_pid: pos_pid, fill_pid: fill_pid}}
  end

  defp create_callback do
    pid = self()
    &(SellSide.fill_update(pid, &1))
  end

  def handle_cast({:fill, execution}, state) do
    IO.puts "fill handle_cast: #{inspect execution}"
    update_position(execution, state)
    {:noreply, state}
  end

  defp update_position(exec = %Client.Execution{order: %Client.OrderResult{direction: "buy"}}, state) do
    PositionAgent.buy(state.position_pid, %{qty: exec.filled, price: exec.price})
  end
  defp update_position(exec = %Client.Execution{order: %Client.OrderResult{direction: "sell"}}, state) do
    PositionAgent.sell(state.position_pid, %{qty: exec.filled, price: exec.price})
  end

  def handle_call({:position}, _from, state) do
    position = PositionAgent.position(state.position_pid)
    {:reply, position, state}
  end
  def handle_call({:nav, price}, _from, state) do
    nav = PositionAgent.nav(state.position_pid, price)
    {:reply, nav, state}
  end

  # def handle_info(:timeout, state = %State{order_id: nil}) do
  #   # no active order
  #   {:ok, last} = last_trade
  #   # IO.puts "Last: #{last.lastSize}@#{last.last}"
  #   {:ok, result} = buy(block_size(state), bid_price(last.last, state))
  #   {:noreply, %State{state | order_id: result.id}, @delay_ms}
  # end
end
