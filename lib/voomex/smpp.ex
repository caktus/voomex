defmodule Voomex.SMPP do
  @moduledoc """
  Voomex.SMPP handles the interaction between the web API and the mobile network operator (MNO).
  """

  @callback send_to_mno(dest_addresses :: [String.t()], message :: String.t()) :: :ok

  @callback_module Application.get_env(:voomex, Voomex.SMPP)[:callback_module]

  @doc """
  Send a message to the destination address
  """
  def send_to_mno(dest_addresses, message) do
    @callback_module.send_to_mno(dest_addresses, message)
  end
end
