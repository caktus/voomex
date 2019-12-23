defmodule Voomex.SMPP do
  @moduledoc """
  Voomex.SMPP handles the interaction between the web API and the mobile network operator (MNO).
  """
  use GenServer

  # External API

  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val, name: __MODULE__)
  end

  def send_to_mno(pid, dest_addr, message) do
    GenServer.call(pid, {:send_to_mno, dest_addr, message})
  end

  def receive_from_mno(pid) do
    GenServer.call(pid, :receive_from_mno)
  end

  # GenServer implementation

  def init(esme) do
    config = Application.get_env(:voomex, Voomex.SMPP)
    host = config[:host]
    port = config[:port]
    system_id = config[:system_id]
    password = config[:password]

    case SMPPEX.ESME.Sync.start_link(host, port) do
      {:ok, esme} ->
        bind = SMPPEX.Pdu.Factory.bind_transceiver(system_id, password)
        {:ok, _bind_resp} = SMPPEX.ESME.Sync.request(esme, bind)
        {:ok, esme}

      {:error, err} ->
        IO.puts(err)
        {:ok, esme}
    end
  end

  def handle_call(:receive_from_mno, _from, esme) do
    [pdu: pdu] = SMPPEX.ESME.Sync.wait_for_pdus(esme)
    {:reply, pdu, esme}
  end

  def handle_call({:send_to_mno, dest_addr, message}, _from, esme) do
    config = Application.get_env(:voomex, Voomex.SMPP)
    source_addr = config[:system_id]
    source_ton = config[:source_ton]
    source_npi = config[:source_npi]
    dest_ton = config[:dest_ton]
    dest_npi = config[:dest_npi]

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
