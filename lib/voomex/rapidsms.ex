defmodule Voomex.RapidSMS do
  @moduledoc """
  Handles communication to RapidSMS
  """

  alias Ecto.UUID

  @doc """
  Send the PDU to RapidSMS
  """
  def send_to_rapidsms(pdu) do
    pdu
    |> pdu_to_request
    |> Voomex.RapidSMS.Worker.new()
    |> Oban.insert()
  end

  @doc """
  Convert a PDU to a request which matches the JSON expected by RapidSMS
  """
  def pdu_to_request(pdu) do
    config = Application.get_env(:voomex, Voomex.SMPP)

    %{
      content: pdu.mandatory.short_message,
      from_addr: pdu.mandatory.source_addr,
      group: nil,
      in_reply_to: nil,
      message_id: UUID.generate(),
      message_type: "user_message",
      timestamp: DateTime.utc_now() |> DateTime.to_string(),
      to_addr: pdu.mandatory.destination_addr,
      transport_name: config[:transport_name],
      transport_type: "sms"
    }
  end

  @doc """
  Send a HTTP post to the configured RapidSMS endpoint
  """
  def post_request(request) do
    config = Application.get_env(:voomex, Voomex.RapidSMS)
    Mojito.post(config[:url], [{"content-type", "application/json"}], request)
  end
end
