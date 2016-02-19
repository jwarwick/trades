defmodule Client.FillServer do
  @moduledoc """
  Interface to the StockFighter Execution websocket
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
  def start_link(s = %Client.StockId{}, callback \\ &(Apex.ap &1)) do
    :crypto.start
    :ssl.start
    :websocket_client.start_link(Client.Url.fill_url(s.account, s.venue, s.stock), 
      __MODULE__, %{account: s.account, venue: s.venue, stock: s.stock, callback: callback})
  end

  ##
  ## Callbacks

  def init(args, _conn_state) do
    {:ok, struct(State, args)}
  end

  def websocket_handle({:text, msg}, _conn_state, state) do
    {:ok, result} = Poison.decode(msg, keys: :atoms, as: Client.Execution)
    order = struct(Client.OrderResult, result.order)
            |> Client.OrderResult.update_fills
    result = %Client.Execution{result | order: order}
    apply(state.callback, [result])
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
end
