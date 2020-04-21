defmodule Voomex.SMPP.Supervisor do
  @moduledoc """
  Supervisor for SMPP processes
  """

  use Supervisor

  @doc false
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    children = [
      Voomex.SMPP.Monitor,
      {Voomex.SMPP.TetherSupervisor, [name: Voomex.SMPP.TetherSupervisor]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
