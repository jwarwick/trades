defmodule Client do
  @moduledoc """
  Client interface for the StockFighter Trades.exec web api
  """

  @doc """
  A simple health check for the api
  """
  def api_status do
    with {:ok, 200, _headers, body_ref} <- :hackney.request(:get, "https://api.stockfighter.io/ob/api/heartbeat"),
         {:ok, body} <- :hackney.body(body_ref),
         {:ok, status} <- Poison.Parser.parse(body),
      do: {:ok, status}
  end

  @doc """
  Get the most recent trade info for a stock
  """
  def quote(venue, stock) do
    with {:ok, 200, _headers, body_ref} <- :hackney.request(:get, quote_url(venue, stock)),
         {:ok, body} <- :hackney.body(body_ref),
         {:ok, q} <- Poison.decode(body, as: Client.Quote),
      do: {:ok, q}
  end

  defp quote_url(venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/quote"
  end

  @doc """
  Get the order book for a stock
  """
  def order_book(venue, stock) do
    with {:ok, 200, _headers, body_ref} <- :hackney.request(:get, order_book_url(venue, stock)),
         {:ok, body} <- :hackney.body(body_ref),
         {:ok, q} <- Poison.Parser.parse(body),
      do: {:ok, q}
  end

  defp order_book_url(venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}"
  end

  @doc """
  Buy a stock. Wrapper around `order`
  """
  def buy(account, venue, stock, price, qty, order_type, api_key) do
    order(%Client.Order{
      account: account, venue: venue, stock: stock,
      price: price, qty: qty, direction: "buy", orderType: order_string(order_type)
    }, api_key)
  end

  defp order_string(:limit), do: "limit"
  defp order_string(:market), do: "market"
  defp order_string(:fok), do: "fill-or-kill"
  defp order_string(:ioc), do: "immediate-or-cancel"

  @doc """
  Place an order for a stock
  """
  def order(order = %Client.Order{}, api_key) do
    {:ok, body} = Poison.encode(order)
    headers = [{"X-Starfighter-Authorization", api_key}]
    with {:ok, 200, _headers, result_ref} <- :hackney.request(:post, 
                                                            order_url(order.venue, order.stock),
                                                            headers,
                                                            body),
         {:ok, result} <- :hackney.body(result_ref),
         {:ok, r} <- Poison.decode(result, as: Client.OrderResult),
      do: {:ok, r}
  end

  defp order_url(venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/orders"
  end
end
