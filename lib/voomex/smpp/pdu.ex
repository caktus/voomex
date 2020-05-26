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
  Create a `submit_sm` message with configured values
  """
  def submit_sm(connection, dest_addr, message) do
    SMPPEX.Pdu.Factory.submit_sm(
      source(connection),
      destination(connection, dest_addr),
      message
    )
  end
end
