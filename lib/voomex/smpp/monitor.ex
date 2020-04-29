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

  @doc """
  Check if the connection was ever started

  While the monitor is initially delaying, the connection is not up and
  is _meant_ not to be up. This is different than if the connection dropped
  sometime after boot and we can handle the states differently.
  """
  def booted?() do
    case :ets.lookup(__MODULE__, :booted) do
      [booted: true] ->
        true

      _ ->
        false
    end
  end

  @impl true
  def init(_) do
    Logger.debug("Starting the monitor", tag: :smpp)

    Process.flag(:trap_exit, true)
    Process.send_after(self(), [:connect, :initial], @connection_boot_delay)

    :ets.new(__MODULE__, [:set, :protected, :named_table])

    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_info([:connect, reason], state) do
    connecting(reason)

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

  defp connecting(:initial) do
    :ets.insert(__MODULE__, {:booted, true})
  end

  defp connecting(_reason), do: :ok

  defp restart_connection() do
    Process.send_after(self(), [:connect, :restart], @connection_retry_delay)
  end
end
