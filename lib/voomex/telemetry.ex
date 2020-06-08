defmodule Voomex.Telemetry do
  @moduledoc false

  use Supervisor

  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      Voomex.Telemetry.Reporters,
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # Database Time Metrics
      summary("voomex.repo.query.total_time", unit: {:native, :millisecond}),
      summary("voomex.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("voomex.repo.query.query_time", unit: {:native, :millisecond}),
      summary("voomex.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("voomex.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # MNO Metrics
      counter("voomex.mno.deliver_sm.count", tags: [:mno, :source_addr]),
      counter("voomex.mno.submit_sm.count", tags: [:mno, :source_addr])
    ]
  end

  defp periodic_measurements do
    []
  end
end

defmodule Voomex.Telemetry.Reporters do
  @moduledoc """
  GenServer to hook up telemetry events on boot

  Attaches reporters after initialization
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :initialize}}
  end

  def handle_continue(:initialize, state) do
    reporters = [
      Voomex.ObanReporter
    ]

    Enum.each(reporters, fn reporter ->
      :telemetry.attach_many(reporter, reporter.events(), &reporter.handle_event/4, [])
    end)

    {:noreply, state}
  end
end
