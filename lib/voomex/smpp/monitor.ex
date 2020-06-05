defmodule Voomex.SMPP.Monitor do
  @moduledoc """
  Monitor the SMPP connection process

  - Starts the connection on a delay
  - Notified when the connection drops and restarts after a delay
  """

  use GenServer

  require Logger

  alias Voomex.SMPP.TetherSupervisor

  @connection_boot_delay 1_500
  @connection_retry_delay 10_000

  defstruct [:connections]

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Check if the connection was ever started

  While the monitor is initially delaying, the connection is not up and
  is _meant_ not to be up. This is different than if the connection dropped
  sometime after boot and we can handle the states differently.
  """
  def booted?(mno, source_addr) do
    case :ets.lookup(__MODULE__, {mno, source_addr}) do
      [{_, booted: true}] ->
        true

      _ ->
        false
    end
  end

  @impl true
  def init(opts) do
    Logger.debug("Starting the monitor", tag: :smpp)

    Process.flag(:trap_exit, true)

    :ets.new(__MODULE__, [:set, :protected, :named_table])

    connections =
      Enum.map(opts[:connections], fn connection ->
        struct(Voomex.SMPP.Connection, connection)
      end)

    Enum.each(connections, fn connection ->
      Process.send_after(self(), [:connect, :initial, connection], @connection_boot_delay)
    end)

    {:ok, %__MODULE__{connections: connections}}
  end

  @impl true
  def handle_info([:connect, reason, connection], state) do
    connecting(reason, connection)

    case TetherSupervisor.start_connection(connection) do
      {:ok, pid} ->
        Process.link(pid)
        Logger.debug("Connected to MNO: #{connection.mno}", tag: :smpp)

        {:noreply, update_connection_pid(state, connection, pid)}

      {:error, error} ->
        Logger.debug("Connection to MNO failed: #{inspect(error)}", tag: :smpp)
        restart_connection(connection)
        {:noreply, state}
    end
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    connection =
      Enum.find(state.connections, fn connection ->
        connection.pid == pid
      end)

    restart_connection(connection)

    {:noreply, update_connection_pid(state, connection, nil)}
  end

  defp connecting(:initial, connection) do
    id = {connection.mno, connection.source_addr}
    :ets.insert(__MODULE__, {id, [booted: true]})
  end

  defp connecting(_reason, _connection), do: :ok

  defp restart_connection(connection) do
    Process.send_after(self(), [:connect, :restart, connection], @connection_retry_delay)
  end

  defp update_connection_pid(state, connection, pid) do
    connections =
      Enum.reject(state.connections, fn existing_connection ->
        existing_connection.mno == connection.mno &&
          existing_connection.source_addr == connection.source_addr
      end)

    connection = %{connection | pid: pid}
    connections = [connection | connections]
    %{state | connections: connections}
  end
end
