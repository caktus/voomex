defmodule Voomex.SMPP do
  @moduledoc """
  Voomex.SMPP handles the interaction between the web API and the mobile network operator (MNO).
  """
  use SMPPEX.Session
  require Logger

  # External API

  def start_link(_state) do
    # Get the MNO host and port
    config = Application.get_env(:voomex, Voomex.SMPP)
    host = config[:host]
    port = config[:port]

    # Start the MNO connection (but don't bind yet)
    {:ok, esme} = SMPPEX.ESME.start_link(host, port, {__MODULE__, []})

    # Name the process
    Process.register(esme, __MODULE__)
    {:ok, esme}
  end

  def send_to_mno(pid, dest_addr, message) do
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

    SMPPEX.Session.send_pdu(pid, submit_sm)
  end

  # GenServer implementation

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @impl true
  def init(_socket, _transport, _args) do
    # send ourselves a message to bind to the MNO
    Kernel.send(self(), :bind)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:bind, state) do
    config = Application.get_env(:voomex, Voomex.SMPP)
    system_id = config[:system_id]
    password = config[:password]
    {:noreply, [SMPPEX.Pdu.Factory.bind_transceiver(system_id, password)], state}
  end

  @impl true
  def handle_resp(pdu, _original_pdu, state) do
    case SMPPEX.Pdu.command_name(pdu) do
      :submit_sm_resp ->
        Logger.info("MNO Submission response: #{inspect(pdu)}")
        {:ok, state}

      :bind_transceiver_resp ->
        Logger.info("MNO Bind transceiver response received: #{inspect(pdu)}")
        {:ok, state}

      _ ->
        Logger.info("MNO other response received: #{inspect(pdu)}")
        {:ok, state}
    end
  end

  @impl true
  def handle_pdu(pdu, state) do
    case SMPPEX.Pdu.command_name(pdu) do
      :deliver_sm ->
        send_to_rapidsms(pdu)

      _ ->
        Logger.info("Got unhandled PDU: #{inspect(pdu)}")
    end

    {:ok, state}
  end

  defp send_to_rapidsms(pdu) do
    Logger.info("FIXME: HTTP POST to RapidSMS: #{inspect(pdu)}")
  end
end
