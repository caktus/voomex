defmodule Voomex.RapidSMS do
  @moduledoc """
  Handles communication to RapidSMS
  """

  alias Ecto.UUID

  @doc """
  Send the PDU to RapidSMS
  """
  def send_to_rapidsms(pdu, mno) do
    parse_pdu_and_mno(pdu, mno)
    |> Voomex.RapidSMS.Worker.new()
    |> Oban.insert()
  end

  @doc """
  Parse the PDU and pull out the data that we need, named by the keys that RapidSMS expects
  """
  def parse_pdu_and_mno(pdu, mno) do
    %{
      content: pdu.mandatory.short_message,
      from_addr: pdu.mandatory.source_addr,
      to_addr: pdu.mandatory.destination_addr,
      mno: mno,
      url: get_url(mno)
    }
    |> map_to_addr()
  end

  @doc """
  Libyana currently sets to_addr to 150 instead of 15015, so we map it properly.
  """
  def map_to_addr(%{mno: "libyana", to_addr: "150"} = args) do
    %{args | to_addr: "15015"}
  end

  def map_to_addr(%{mno: "libyana", to_addr: "21810020"} = args) do
    %{args | to_addr: "10020"}
  end

  def map_to_addr(%{mno: "libyana", to_addr: "21810040"} = args) do
    %{args | to_addr: "10040"}
  end

  def map_to_addr(args) do
    args
  end

  @doc """
  Prepare the map expected by RapidSMS
  """
  def prepare_body(args) do
    %{
      content: args["content"],
      from_addr: args["from_addr"],
      group: nil,
      in_reply_to: nil,
      message_id: UUID.generate(),
      message_type: "user_message",
      timestamp: DateTime.utc_now() |> DateTime.to_string(),
      to_addr: args["to_addr"],
      transport_name: "#{args["mno"]}_smpp_transport_#{args["to_addr"]}",
      transport_type: "sms"
    }
  end

  @doc """
  Return the RapidSMS URL for this MNO from our config
  """
  def get_url(mno) do
    Application.get_env(:voomex, Voomex.RapidSMS)
    |> Keyword.get(:connections, [])
    |> Enum.find(%{}, fn connection -> connection.mno == mno end)
    |> Map.get(:url)
  end
end
