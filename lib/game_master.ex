defmodule GameMaster do
  @moduledoc """
  Functions to interface with the StockFighter GameMaster

  Can start, restart, and stop levels.
  """

  @base_url "https://www.stockfighter.io/gm"

  @doc """
  List the available levels.

  Not yet implemented by the server.
  """
  def list_levels do
    levels_url |> make_request(:get)
  end

  @doc """
  Start the named level. Expect an atom as the level name.
  """
  def start_level(level) when is_atom(level) do
    "#{@base_url}/levels/#{Atom.to_string(level)}" |> make_request(:post)
  end

  @doc """
  Stop the named instance
  """
  def stop_level(instance) do
    "#{@base_url}/instances/#{instance}/stop" |> make_request(:post)
  end

  @doc """
  Restart the named instance
  """
  def restart_level(instance) do
    "#{@base_url}/instances/#{instance}/restart" |> make_request(:post)
  end

  @doc """
  Resume the named instance
  """
  def resume_level(instance) do
    "#{@base_url}/instances/#{instance}/resume" |> make_request(:post)
  end

  @doc """
  Status of an instance
  """
  def status(instance) do
    "#{@base_url}/instances/#{instance}" |> make_request(:get)
  end

  @doc """
  Build a Client.StockId struct from the data returned from `start_level`
  """
  def make_stock_id(start_data) do
    venue = start_data["venues"] |> List.first
    stock = start_data["tickers"] |> List.first
    account= start_data["account"]
    %Client.StockId{venue: venue, stock: stock, account: account}
  end

  @doc """
  Extract the instance id from the data returned from `start_level`
  """
  def instance_id(start_data), do: start_data["instanceId"]


  defp make_request(url, action) do
    with {:ok, 200, _headers, body_ref} <- :hackney.request(action, url, auth_header()),
         {:ok, body} <- :hackney.body(body_ref),
         {:ok, parsed_body} <- Poison.Parser.parse(body),
     do: {:ok, parsed_body}
  end

  @doc """
  The API key for executing actions on an exchange.

  Read from an environment variable defined in the `config` directory.
  """
  def api_key, do: Application.get_env(:trades, :stockfighter)[:api_key]

  defp auth_header, do: [{"X-Starfighter-Authorization", api_key()}]

  defp levels_url, do: "#{@base_url}/levels"
end

