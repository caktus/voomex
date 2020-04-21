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

  defstruct [:connection_pid]

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    Logger.debug("Starting the monitor", tag: :smpp)

    Process.flag(:trap_exit, true)
    Process.send_after(self(), :connect, @connection_boot_delay)

    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_info(:connect, state) do
    case TetherSupervisor.start_connection() do
      {:ok, pid} ->
        Process.link(pid)
        Logger.debug("Connected to MNO", tag: :smpp)
        {:noreply, Map.put(state, :connection_pid, pid)}

      {:error, error} ->
        Logger.debug("Connection could not connect - #{inspect(error)}", tag: :smpp)
        restart_connection()
        {:noreply, state}
    end
  end

  def handle_info({:EXIT, pid, _reason}, state = %{connection_pid: pid}) do
    restart_connection()
    {:noreply, Map.put(state, :connection_pid, nil)}
  end

  defp restart_connection() do
    Process.send_after(self(), :connect, @connection_retry_delay)
  end
end
