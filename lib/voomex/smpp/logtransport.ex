defmodule Voomex.SMPP.LogTransportSession do
  @moduledoc """
  Proxy implementation of TransportSession that adds logging at various steps, then
  passes processing to SMPPEX.Session.
  """

  require Logger
  @behaviour SMPPEX.TransportSession

  alias Voomex.SMPP.{Connection, PDU}

  @impl true
  def init(socket, transport, opts), do: SMPPEX.Session.init(socket, transport, opts)

  @impl true
  def handle_pdu({:pdu, pdu} = pdu_parse_result, state) do
    log("INCOMING:", state, pdu)
    SMPPEX.Session.handle_pdu(pdu_parse_result, state)
  end

  @impl true
  def handle_pdu({:unparsed_pdu, raw_pdu, error} = pdu_parse_result, state) do
    log("INCOMING unparsed handle_pdu: #{inspect(raw_pdu)} : #{inspect(error)}", state)
    SMPPEX.Session.handle_pdu(pdu_parse_result, state)
  end

  @impl true
  def handle_send_pdu_result(pdu, send_pdu_result, state) do
    log("OUTGOING:", state, pdu)
    SMPPEX.Session.handle_send_pdu_result(pdu, send_pdu_result, state)
  end

  @impl true
  def handle_call(request, from, state) do
    log("handle_call: #{inspect(request)}", state)
    SMPPEX.Session.handle_call(request, from, state)
  end

  @impl true
  def handle_cast(request, state) do
    log("handle_cast: #{inspect(request)}", state)
    SMPPEX.Session.handle_cast(request, state)
  end

  @impl true
  def handle_info(request, state), do: SMPPEX.Session.handle_info(request, state)

  @impl true
  def handle_socket_closed(state) do
    log("SOCKET CLOSED", state)
    SMPPEX.Session.handle_socket_closed(state)
  end

  @impl true
  def handle_socket_error(error, state) do
    log("SOCKET ERROR", state)
    SMPPEX.Session.handle_socket_error(error, state)
  end

  @impl true
  def terminate(reason, state) do
    log("TERMINATE #{reason}", state)
    SMPPEX.Session.terminate(reason, state)
  end

  @impl true
  def code_change(old_vsn, state, extra) do
    log("CODE_CHANGE", state)
    SMPPEX.Session.code_change(old_vsn, state, extra)
  end

  defp is_enquire(pdu) do
    SMPPEX.Pdu.command_name(pdu) in [:enquire_link, :enquire_link_resp]
  end

  defp transport_name(state) do
    Connection.transport_name(state.module_state.connection)
  end

  defp log(message, state, pdu) do
    log_message = "#{transport_name(state)} #{message} #{inspect(PDU.pdu_for_log(pdu))}"

    case is_enquire(pdu) do
      true ->
        Logger.debug(log_message)

      false ->
        Logger.info(log_message)
    end
  end

  defp log(message, state) do
    Logger.info("#{transport_name(state)} #{message}")
  end
end
