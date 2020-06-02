defmodule Voomex.SMPP.PDU do
  @moduledoc """
  Generates the proper PDU messages
  """

  @doc """
  Source tuple for messages
  """
  def source(connection) do
    {connection.source_addr, connection.source_ton, connection.source_npi}
  end

  @doc """
  Destination tuple for messages
  """
  def destination(connection, dest_addr) do
    {dest_addr, connection.dest_ton, connection.dest_npi}
  end

  @doc """
  Return `submit_sm` PDU(s)

  If the message is long, the 3rd param should be a list of parts and we'll set the
  :esm_class flag to mark it as a multipart message, returning a list of PDUs.

  If the message is not long, the 3rd param should be a single binary message, and we'll
  return a single PDU.
  """
  def submit_sm(connection, dest_addr, parts) when is_list(parts) do
    Enum.map(parts, fn message ->
      submit_sm(connection, dest_addr, message)
      # esm_class=0x40 signifies multipart
      |> SMPPEX.Pdu.set_mandatory_field(:esm_class, 0x40)
    end)
  end

  def submit_sm(connection, dest_addr, message) do
    SMPPEX.Pdu.Factory.submit_sm(
      source(connection),
      destination(connection, dest_addr),
      message
    )
  end
end
