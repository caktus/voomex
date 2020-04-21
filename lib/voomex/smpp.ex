defmodule Voomex.SMPP do
  @moduledoc """
  Voomex.SMPP handles the interaction between the web API and the mobile network operator (MNO).
  """

  alias Voomex.SMPP.Connection
  alias Voomex.SMPP.PDU

  @doc """
  Send a message to the destination address
  """
  def send_to_mno(dest_addr, message) do
    submit_sm = PDU.submit_sm(dest_addr, message)
    SMPPEX.Session.send_pdu(Connection, submit_sm)
  end
end
