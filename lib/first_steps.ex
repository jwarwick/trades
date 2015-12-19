defmodule FirstSteps do
  @moduledoc """
  Buy 100 shares of the specified stock
  """

  @api_key "cbfb31ca0bd485da4e54ca12fd287a0f8cf7a234"
  @venue "SOKYEX"
  @stock "UFYP"
  @account "JB47891558"
  @quantity 100

  @doc """
  Buy 100 shares of the stock at the specified price using immediate-or-cancel order type
  """
  def buy(price) do
    Client.buy(@account, @venue, @stock, price, @quantity, :limit, @api_key)
  end

end
