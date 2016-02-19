defmodule Client.Url do
  @moduledoc """
  URLs to access StockFighter Trades API
  """

  @default_host "https://api.stockfighter.io"
  @default_base_path "/ob/api"

  @host Application.get_env(:trades, :stockfighter)[:host] || @default_host
  @path Application.get_env(:trades, :stockfighter)[:base_path] || @default_base_path
  @host_path "#{@host}#{@path}"

  @default_wss "wss://api.stockfighter.io"
  @default_wss_base_path "/ob/api/ws"

  @wss_host Application.get_env(:trades, :stockfighter)[:wss_host] || @default_wss
  @wss_path Application.get_env(:trades, :stockfighter)[:wss_base_path] || @default_wss_base_path
  @wss_path "#{@wss_host}#{@wss_path}"

  def heartbeat_url, do: "#{@host_path}/heartbeat"

  def venue_heartbeat_url(venue), do: "#{@host_path}/venues/#{venue}/heartbeat"

  def stock_list_url(venue), do: "#{@host_path}/venues/#{venue}/stocks"

  def quote_url(venue, stock), do: "#{@host_path}/venues/#{venue}/stocks/#{stock}/quote"

  def order_book_url(venue, stock), do: "#{@host_path}/venues/#{venue}/stocks/#{stock}"

  def order_url(venue, stock), do: "#{@host_path}/venues/#{venue}/stocks/#{stock}/orders"

  def order_status_url(order_id, venue, stock), do: "#{@host_path}/venues/#{venue}/stocks/#{stock}/orders/#{order_id}"

  def fill_url(account, venue, nil) do
    "#{@wss_path}/#{account}/venues/#{venue}/executions"
  end
  def fill_url(account, venue, stock) do
    "#{@wss_path}/#{account}/venues/#{venue}/executions/stocks/#{stock}"
  end

  def quote_url(account, venue, nil) do
    "#{@wss_path}/#{account}/venues/#{venue}/tickertape"
  end
  def quote_url(account, venue, stock) do
    "#{@wss_path}/#{account}/venues/#{venue}/tickertape/stocks/#{stock}"
  end
end
