defmodule Voomex.SMPP.Connection do
  @moduledoc """
  Voomex.SMPP.Connection connects to the MNO network
  """

  use SMPPEX.Session

  require Logger

  alias Voomex.RapidSMS

  @split_at 130

  # struct with defaults for the connection, which can be overriden in config.exs
  defstruct mno: nil,
            source_addr: nil,
            host: nil,
            port: nil,
            system_id: nil,
            password: nil,
            source_ton: 0,
            source_npi: 0,
            dest_ton: 1,
            dest_npi: 1,
            data_coding: 8,
            enquire_link_limit: 5_000,
            service_type: nil,
            pid: nil

  # External API

  def name(connection) do
    name(connection.mno, connection.source_addr)
  end

  def name(mno, source_addr) do
    {:via, Registry, {Voomex.SMPP.ConnectionRegistry, {mno, source_addr}}}
  end

  def transport_name(connection) do
    "#{connection.mno}_#{connection.source_addr}"
  end

  def start_link(connection) do
    # Start the MNO connection (but don't bind yet)
    # copy/paste SMPPEX.ESME.start_link in order to use our LogTransportSession instead of Session
    mod_with_args = {__MODULE__, connection}
    host = connection.host
    port = connection.port
    transport = :ranch_tcp
    timeout = 5000
    sock_opts = [:binary, {:packet, 0}, {:active, :once}]
    esme_opts = [enquire_link_limit: connection.enquire_link_limit]

    case transport.connect(SMPPEX.Compat.to_charlist(host), port, sock_opts, timeout) do
      {:ok, socket} ->
        session_opts = {Voomex.SMPP.LogTransportSession, [mod_with_args, esme_opts], :esme}

        case SMPPEX.TransportSession.start_link(socket, transport, session_opts) do
          {:ok, pid} ->
            {:ok, pid}

          {:error, _} = error ->
            transport.close(socket)
            error
        end

      {:error, _} = error ->
        error
    end
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
    # update our connection struct with our PID
    connection = %{connection | pid: self()}

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
  def handle_info(:bind, %{connection: connection} = state) do
    opts = %{
      # Using SMPP version 3.4
      interface_version: 0x34
    }

    pdu = SMPPEX.Pdu.Factory.bind_transceiver(connection.system_id, connection.password, opts)

    {:noreply, [pdu], state}
  end

  @impl true
  def handle_pdu(pdu, state) do
    case SMPPEX.Pdu.command_name(pdu) do
      :deliver_sm ->
        :telemetry.execute([:voomex, :mno, :deliver_sm], %{count: 1}, state.connection)
        RapidSMS.send_to_rapidsms(pdu, state.connection.mno)
        resp = SMPPEX.Pdu.Factory.deliver_sm_resp() |> SMPPEX.Pdu.as_reply_to(pdu)
        {:ok, [resp], state}

      _ ->
        Logger.error("Got unhandled PDU: #{inspect(pdu)}")
        {:ok, state}
    end
  end

  @impl true
  def handle_call({:submit_sm, dest_addr, message}, _from, state) do
    :telemetry.execute([:voomex, :mno, :submit_sm], %{count: 1}, state.connection)

    # ref_num is a 2 byte number which must be the same for all parts of a split message
    ref_num = rem(state.ref_num + 1, 0xFF)

    # encode the message as UTF16be
    message = :unicode.characters_to_binary(message, :utf8, {:utf16, :big})

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
