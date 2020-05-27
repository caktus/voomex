defmodule Voomex.SMPP.Implementation do
  @moduledoc """
  Real implementation for the SMPP client
  """

  @behaviour Voomex.SMPP

  alias Voomex.SMPP.Connection

  @impl true
  def send_submit_sm(mno, source_addr, dest_addr, message) do
    case Voomex.SMPP.Monitor.booted?(mno, source_addr) do
      true ->
        Connection.name(mno, source_addr)
        |> SMPPEX.Session.call({:submit_sm, dest_addr, message})

      false ->
        {:error, :not_booted}
    end
  end

  @impl true
  def send_to_mno(mno, source_addr, dest_addresses, message) do
    Enum.each(dest_addresses, fn dest_addr ->
      %{dest_addr: dest_addr, message: message, mno: mno, source_addr: source_addr}
      |> Voomex.SMPP.Worker.new()
      |> Oban.insert()
    end)
  end
end
