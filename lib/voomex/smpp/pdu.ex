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
    |> SMPPEX.Pdu.set_mandatory_field(:service_type, connection.service_type)
    |> SMPPEX.Pdu.set_mandatory_field(:data_coding, connection.data_coding)
  end

  @doc """
  Return a pdu formatted for logging.

  We change command_id and command_status from integers to their code names and then
  drop the ref field, which we aren't using.
  """
  def pdu_for_log(pdu) do
    pdu
    |> Map.from_struct()
    |> Map.put(:command_id, SMPPEX.Pdu.command_name(pdu))
    |> Map.put(:command_status, SMPPEX.Pdu.Errors.format(pdu.command_status))
    |> Map.drop([:ref])
  end
end
