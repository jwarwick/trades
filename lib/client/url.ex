defmodule Client.Url do
  @moduledoc """
  URLs to access StockFighter Trades API
  """

  def heartbeat_url, do: "https://api.stockfighter.io/ob/api/heartbeat"

  def venue_heartbeat_url(venue) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/heartbeat"
  end

  def stock_list_url(venue) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks"
  end

  def quote_url(venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/quote"
  end

  def order_book_url(venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}"
  end

  def order_url(venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/orders"
  end

  def order_status_url(order_id, venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/orders/#{order_id}"
  end
end
