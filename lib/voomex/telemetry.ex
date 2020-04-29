defmodule Voomex.Telemetry do
  @moduledoc """
  GenServer to hook up telemetry events on boot

  Attaches reporters after initialization
  """

  use GenServer

  alias Voomex.ObanReporter

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :initialize}}
  end

  def handle_continue(:initialize, state) do
    reporters = [
      ObanReporter
    ]

    Enum.each(reporters, fn reporter ->
      :telemetry.attach_many(reporter, reporter.events(), &reporter.handle_event/4, [])
    end)

    {:noreply, state}
  end
end
