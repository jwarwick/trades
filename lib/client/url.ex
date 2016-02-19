defmodule Client.Url do
  @moduledoc """
  URLs to access StockFighter Trades API
  """

  @default_host "https://api.stockfighter.io"
  @default_base_path "/ob/api"

  @host Application.get_env(:trades, :stockfighter)[:host] || @default_host
  @path Application.get_env(:trades, :stockfighter)[:base_path] || @default_base_path
  @host_path "#{@host}#{@path}"

  def heartbeat_url, do: "#{@host_path}/heartbeat"

  def venue_heartbeat_url(venue), do: "#{@host_path}/venues/#{venue}/heartbeat"

  def stock_list_url(venue), do: "#{@host_path}/venues/#{venue}/stocks"

  def quote_url(venue, stock), do: "#{@host_path}/venues/#{venue}/stocks/#{stock}/quote"

  def order_book_url(venue, stock), do: "#{@host_path}/venues/#{venue}/stocks/#{stock}"

  def order_url(venue, stock), do: "#{@host_path}/venues/#{venue}/stocks/#{stock}/orders"

  def order_status_url(order_id, venue, stock), do: "#{@host_path}/venues/#{venue}/stocks/#{stock}/orders/#{order_id}"
end
