defmodule Voomex.SMPP.Connection do
  @moduledoc """
  Voomex.SMPP.Connection connects to the MNO network
  """

  use SMPPEX.Session

  require Logger

  alias Voomex.RapidSMS

  @split_at 130

  defstruct [
    :mno,
    :source_addr,
    :source_ton,
    :source_npi,
    :dest_ton,
    :dest_npi,
    :host,
    :port,
    :system_id,
    :password,
    :pid
  ]

  @doc """
  Turns a config connection into a internal `Connection` struct

  Takes `connection.source_addrs` and maps to multiple connections each with a single `source_addr`.
  """
  def initialize_connection_struct(connection) do
    Enum.map(connection.source_addrs, fn source_addr ->
      connection =
        connection
        |> Map.put(:source_addr, source_addr)
        |> Map.delete(:source_addrs)

      struct(Voomex.SMPP.Connection, connection)
    end)
  end

  # External API

  def name(connection) do
    name(connection.mno, connection.source_addr)
  end

  def name(mno, source_addr) do
    {:via, Registry, {Voomex.SMPP.ConnectionRegistry, {mno, source_addr}}}
  end

  def start_link(connection) do
    # Start the MNO connection (but don't bind yet)
    SMPPEX.ESME.start_link(connection.host, connection.port, {__MODULE__, connection})
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
  def init(_socket, _transport, connection) do
    Registry.register(
      Voomex.SMPP.ConnectionRegistry,
      {connection.mno, connection.source_addr},
      self()
    )

    # send ourselves a message to bind to the MNO
    send(self(), :bind)

    {:ok, %{connection: connection, ref_num: 0}}
  end

  @impl true
  def handle_info(:bind, state = %{connection: connection}) do
    opts = %{
      # Using SMPP version 3.4
      interface_version: 0x34
    }

    pdu = SMPPEX.Pdu.Factory.bind_transceiver(connection.system_id, connection.password, opts)
    Logger.info("Outgoing bind_transceiver pdu: #{inspect(pdu)}")

    {:noreply, [pdu], state}
  end

  @impl true
  def handle_resp(pdu, _original_pdu, state) do
    case SMPPEX.Pdu.command_name(pdu) do
      :submit_sm_resp ->
        Logger.info("MNO submit_sm_resp: #{inspect(pdu)}")
        {:ok, state}

      :bind_transceiver_resp ->
        Logger.info("MNO bind_transceiver_resp: #{inspect(pdu)}")
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
        :telemetry.execute([:voomex, :mno, :deliver_sm], %{count: 1}, state.connection)
        RapidSMS.send_to_rapidsms(pdu, state.connection.mno)

      _ ->
        Logger.info("Got unhandled PDU: #{inspect(pdu)}")
    end

    {:ok, state}
  end

  @impl true
  def handle_call({:submit_sm, dest_addr, message}, _from, state) do
    :telemetry.execute([:voomex, :mno, :submit_sm], %{count: 1}, state.connection)

    # ref_num is a 2 byte number which must be the same for all parts of a split message
    ref_num = rem(state.ref_num + 1, 0xFF)

    case SMPPEX.Pdu.Multipart.split_message(ref_num, message, @split_at) do
      {:ok, :unsplit} ->
        Logger.info("#{byte_size(message)} byte message didn't need to be split.")
        pdu = Voomex.SMPP.PDU.submit_sm(state.connection, dest_addr, message)
        {:reply, :ok, [pdu], %{state | ref_num: ref_num}}

      {:ok, :split, parts} ->
        Logger.info("Message is being split into #{length(parts)} parts.")
        # since called with a list of parts, this will return a list
        pdu_list = Voomex.SMPP.PDU.submit_sm(state.connection, dest_addr, parts)
        {:reply, :ok, pdu_list, %{state | ref_num: ref_num}}

      {:error, reason} ->
        Logger.error("Could not split message (#{message}). Error: #{inspect(reason)}")
        {:reply, :ok, %{state | ref_num: ref_num}}
    end
  end
end
