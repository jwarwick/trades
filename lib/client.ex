defmodule Client do
  @moduledoc """
  Client interface for the StockFighter Trades.exec web api
  """

  alias Client.Url

  defmodule StockId do
    defstruct [:venue, :stock, :account]
  end

  defmodule Action do
    defstruct [:price, :qty, :order_type, :direction]
  end

  @doc """
  A simple health check for the api
  """
  def api_status do
    {:ok, body} = Url.heartbeat_url |> get_body
    Poison.Parser.parse(body)
  end

  @doc """
  A simple health check for a venue
  """
  def venue_status(%StockId{venue: venue}), do: venue_status(venue)
  def venue_status(venue) do
    {:ok, body} = Url.venue_heartbeat_url(venue) |> get_body
    Poison.Parser.parse(body)
  end

  @doc """
  List the stocks on a venue
  """
  def stock_list(%StockId{venue: venue}), do: stock_list(venue)
  def stock_list(venue) do
    {:ok, body} = Url.stock_list_url(venue) |> get_body
    Poison.Parser.parse(body)
  end

  @doc """
  Get the most recent trade info for a stock
  """
  def stock_quote(%StockId{venue: venue, stock: stock}), do: stock_quote(venue, stock)
  def stock_quote(venue, stock) do
    {:ok, body} = Url.quote_url(venue, stock) |> get_body
    Poison.decode(body, as: Client.Quote)
  end

  @doc """
  Get the order book for a stock
  """
  def order_book(%StockId{venue: venue, stock: stock}), do: order_book(venue, stock)
  def order_book(venue, stock) do
    {:ok, body} = Url.order_book_url(venue, stock) |> get_body
    Poison.Parser.parse(body)
  end

  @doc """
  Buy a stock
  """
  def buy(s = %StockId{}, %{price: p, qty: q, order_type: t}) do
    place_order(s, %Action{price: p, qty: q, direction: :buy, order_type: t})
  end

  @doc """
  Sell a stock
  """
  def sell(s = %StockId{}, %{price: p, qty: q, order_type: t}) do
    place_order(s, %Action{price: p, qty: q, direction: :sell, order_type: t})
  end

  @doc """
  Place an order for a stock
  """
  def place_order(s = %StockId{}, a = %Action{}) do
    order(%Client.Order{
      account: s.account, venue: s.venue, stock: s.stock,
      price: a.price, qty: a.qty, direction: direction_string(a.direction), orderType: order_string(a.order_type)
    })
  end

  defp order_string(:limit), do: "limit"
  defp order_string(:market), do: "market"
  defp order_string(:fok), do: "fill-or-kill"
  defp order_string(:ioc), do: "immediate-or-cancel"

  defp direction_string(:buy), do: "buy"
  defp direction_string(:sell), do: "sell"

  defp order(order = %Client.Order{}) do
    {:ok, body} = Poison.encode(order)
    order_request(:post, Url.order_url(order.venue, order.stock), body)
  end

  @doc """
  Get the status for an order
  """
  def order_status(o = %Client.OrderResult{}), do: order_status(o.id, o.venue, o.symbol)
  def order_status(order_id, venue, stock) do
    order_request(:get, Url.order_status_url(order_id, venue, stock))
  end

  @doc """
  Cancel an order
  """
  def cancel(o = %Client.OrderResult{}), do: cancel(o.id, o.venue, o.symbol)
  def cancel(order_id, venue, stock) do
    order_request(:delete, Url.order_status_url(order_id, venue, stock))
  end

  defp order_request(action, url, body \\ "") do
    with {:ok, 200, _headers, result_ref} <- :hackney.request(action,
                                                            url,
                                                            auth_header(),
                                                            body),
         {:ok, result} <- :hackney.body(result_ref),
         {:ok, r} <- Poison.decode(result, keys: :atoms, as: Client.OrderResult),
         r = Client.OrderResult.update_fills(r),
      do: {:ok, r}
  end

  defp get_body(url) do
    with {:ok, 200, _headers, body_ref} <- :hackney.request(:get, url),
         {:ok, body} <- :hackney.body(body_ref),
      do: {:ok, body}
  end

  @doc """
  The API key for executing actions on an exchange.

  Read from an environment variable defined in the `config` directory.
  """
  def api_key, do: Application.get_env(:trades, :stockfighter)[:api_key]

  defp auth_header, do: [{"X-Starfighter-Authorization", api_key()}]
end
