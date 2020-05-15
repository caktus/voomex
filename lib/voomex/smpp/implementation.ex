defmodule Voomex.SMPP.Implementation do
  @moduledoc """
  Real implementation for the SMPP client
  """

  @behaviour Voomex.SMPP

  alias Voomex.SMPP.Connection

  @impl true
  def send_submit_sm(mno, from_addr, submit_sm) do
    case Voomex.SMPP.Monitor.booted?(mno, from_addr) do
      true ->
        SMPPEX.Session.send_pdu(Connection.name(mno, from_addr), submit_sm)

      false ->
        {:error, :not_booted}
    end
  end

  @impl true
  def send_to_mno(mno, from_addr, dest_addresses, message) do
    Enum.each(dest_addresses, fn dest_addr ->
      %{dest_addr: dest_addr, message: message, mno: mno, from_addr: from_addr}
      |> Voomex.SMPP.Worker.new()
      |> Oban.insert()
    end)
  end
end
