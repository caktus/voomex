defmodule Voomex.SMPP do
  @moduledoc """
  Voomex.SMPP handles the interaction between the web API and the mobile network operator (MNO).
  """
  use GenServer

  def send_to_mno(pid, dest_addr, message) do
    GenServer.call(pid, {:send_to_mno, dest_addr, message})
  end

  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val, name: MySMPP)
  end

  def init(esme) do
    {host, port, system_id, password} = {"localhost", 2775, "10030", "pass30"}

    case SMPPEX.ESME.Sync.start_link(host, port) do
      {:ok, esme} ->
        bind = SMPPEX.Pdu.Factory.bind_transmitter(system_id, password)
        {:ok, _bind_resp} = SMPPEX.ESME.Sync.request(esme, bind)
        {:ok, esme}

      {:error, err} ->
        IO.puts(err)
        {:ok, esme}
    end
  end

  def handle_call({:send_to_mno, dest_addr, message}, _from, esme) do
    {source_addr, source_ton, source_npi, dest_ton, dest_npi} = {"10030", 1, 1, 1, 1}

    submit_sm =
      SMPPEX.Pdu.Factory.submit_sm(
        {source_addr, source_ton, source_npi},
        {dest_addr, dest_ton, dest_npi},
        message
      )

    {:ok, submit_sm_resp} = SMPPEX.ESME.Sync.request(esme, submit_sm)
    {:reply, submit_sm_resp, esme}
  end
end
