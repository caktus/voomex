defmodule Voomex.RapidSMS do
  @moduledoc """
  Handles communication to RapidSMS
  """

  require Logger

  @doc """
  Send the PDU back to RapidSMS
  """
  def send_message(pdu) do
    Logger.info("FIXME: HTTP POST to RapidSMS: #{inspect(pdu)}")
  end
end
