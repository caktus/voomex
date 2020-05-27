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

  def handle_event([:smppex, :session, :handle_resp, :enquire_link_resp], _measure, _metadata, _) do
    Logger.info("SMPP connection received an enquire_link response", type: :smpp)
  end
end
