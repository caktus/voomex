defmodule Voomex.SMPPEXReporter do
  @moduledoc """
  Report on SMPPEX events
  """

  require Logger

  def events() do
    [
      [:smppex, :session, :handle_resp, :enquire_link_resp]
    ]
  end

  def handle_event(
        [:smppex, :session, :handle_resp, :enquire_link_resp],
        _measure,
        %{pdu: pdu},
        _
      ) do
    pdu_map =
      Map.from_struct(pdu)
      # change command_id to more readable command_name
      |> Map.put(:command_name, SMPPEX.Pdu.command_name(pdu))
      |> Map.drop([:command_id, :ref])

    Logger.info("SMPP #{inspect(pdu_map)}", type: :smpp)
  end
end
