defmodule Voomex.SMPP do
  @moduledoc """
  Voomex.SMPP handles the interaction between the web API and the mobile network operator (MNO).
  """

  @callback send_submit_sm(
              mno :: String.t(),
              source_addr :: String.t(),
              dest_addr :: String.t(),
              message :: String.t()
            ) ::
              :ok | {:error, atom()}

  @callback send_to_mno(
              mno :: String.t(),
              source_addr :: String.t(),
              dest_addresses :: [String.t()],
              message :: String.t()
            ) ::
              :ok

  @callback_module Application.get_env(:voomex, Voomex.SMPP)[:callback_module]

  @doc """
  Send a message to the destination address
  """
  def send_submit_sm(mno, source_addr, dest_addr, submit_sm) do
    @callback_module.send_submit_sm(mno, source_addr, dest_addr, submit_sm)
  end

  @doc """
  Send a message to the destination address
  """
  def send_to_mno(mno, source_addr, dest_addresses, message) do
    @callback_module.send_to_mno(mno, source_addr, dest_addresses, message)
  end
end
