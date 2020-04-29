defmodule Voomex.SMPP.Worker do
  @moduledoc """
  Oban worker for SMPP
  """

  use Oban.Worker, queue: :smpp

  alias Voomex.SMPP.Connection
  alias Voomex.SMPP.PDU

  # TODO maybe turn this into a single job per dest_addr, that way
  # each job can fail independently and not retry and resend messages
  # above the failure
  def perform(%{"dest_addresses" => dest_addresses, "message" => message}, _job) do
    Enum.each(dest_addresses, fn dest_addr ->
      submit_sm = PDU.submit_sm(dest_addr, message)

      # TODO validate what comes back from this, raise an error if there is one
      SMPPEX.Session.send_pdu(Connection, submit_sm)
    end)

    :ok
  end
end
