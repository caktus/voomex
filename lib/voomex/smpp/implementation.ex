defmodule Voomex.SMPP.Implementation do
  @moduledoc """
  Real implementation for the SMPP client
  """

  @behaviour Voomex.SMPP

  alias Voomex.SMPP.Connection
  alias Voomex.SMPP.PDU

  @impl true
  def send_to_mno(dest_addresses, message) do
    Enum.map(dest_addresses, fn dest_addr ->
      submit_sm = PDU.submit_sm(dest_addr, message)
      SMPPEX.Session.send_pdu(Connection, submit_sm)
    end)
  end
end
