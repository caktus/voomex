defmodule Voomex.SMPP.PDU do
  @moduledoc """
  Generates the proper PDU messages
  """

  @doc false
  def config(), do: Application.get_env(:voomex, Voomex.SMPP)

  @doc """
  Source tuple for messages
  """
  def source(source_addr, config) do
    source_ton = config[:source_ton]
    source_npi = config[:source_npi]

    {source_addr, source_ton, source_npi}
  end

  @doc """
  Destination tuple for messages
  """
  def destination(dest_addr, config) do
    dest_ton = config[:dest_ton]
    dest_npi = config[:dest_npi]

    {dest_addr, dest_ton, dest_npi}
  end

  @doc """
  Create a `submit_sm` message with configured values
  """
  def submit_sm(from_addr, dest_addr, message, config \\ config()) do
    SMPPEX.Pdu.Factory.submit_sm(
      source(from_addr, config),
      destination(dest_addr, config),
      message
    )
  end
end
