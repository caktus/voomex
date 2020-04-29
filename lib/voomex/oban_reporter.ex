defmodule Voomex.ObanReporter do
  @moduledoc """
  Report on Oban events

  Print locally any exceptions that happen to see in the console log.
  """

  require Logger

  def events() do
    [
      [:oban, :failure]
    ]
  end

  def handle_event([:oban, :failure], _measure, %{error: :not_booted}, _) do
    Logger.warn("SMPP Connection not alive yet, job failed")
  end

  def handle_event([:oban, :failure], _measure, meta, _) do
    Logger.error(Exception.format(:error, meta.error, meta.stack))
  end
end
