defmodule Client.QuoteServer do
  @moduledoc """
  Interface to the StockFighter TickerTape websocket
  """

  @behaviour :websocket_client_handler

  defmodule State do
    defstruct [:account, :venue, :stock, :callback]
  end

  ##
  ## Interface

  @doc """
  Create a server to connect to the websocket
  """
  def start_link(account, venue), do: start_link(account, venue, &IO.inspect/1)
  def start_link(account, venue, callback), do: start_link(account, venue, nil, callback)
  def start_link(account, venue, stock, callback) do
    :crypto.start
    :ssl.start
    :websocket_client.start_link(ticker_url(account, venue, stock), 
      __MODULE__, %{account: account, venue: venue, stock: stock, callback: callback})
  end

  ##
  ## Callbacks

  def init(args, _conn_state) do
    {:ok, struct(State, args)}
  end

  def websocket_handle({:text, msg}, _conn_state, state) do
    {:ok, q} = Poison.decode(msg, as: %{"quote" => Client.Quote})
    q = %Client.Quote{q["quote"] | ok: true}
    apply(state.callback, [q])
    {:ok, state}
  end
  def websocket_handle(_msg, _conn_state, state) do
    {:ok, state}
  end

  def websocket_info(_msg, _conn_state, state) do
    {:ok, state}
  end

  def websocket_terminate(_msg, _conn_state, _state) do
    :ok
  end

  ##
  ## Helper Functions

  defp ticker_url(account, venue, nil) do
    "wss://api.stockfighter.io/ob/api/ws/#{account}/venues/#{venue}/tickertape"
  end
  defp ticker_url(account, venue, stock) do
    "wss://api.stockfighter.io/ob/api/ws/#{account}/venues/#{venue}/tickertape/stocks/#{stock}"
  end

end
