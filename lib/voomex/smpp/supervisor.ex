defmodule Voomex.SMPP.Supervisor do
  @moduledoc """
  Supervisor for SMPP processes
  """

  use Supervisor
  alias Voomex.SMPP.Connection
  alias Voomex.SMPP.{Monitor, TetherSupervisor}

  @doc false
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    config = Application.get_env(:voomex, Voomex.SMPP, [])
    connections = Keyword.get(config, :connections, [])

    children =
      connections
      |> Enum.flat_map(&Connection.initialize_connection_struct/1)
      |> Enum.map(fn connection ->
        transport_name = "#{connection.mno}_smpp_transport_#{connection.source_addr}"

        Supervisor.child_spec({TetherSupervisor, [name: TetherSupervisor.name(connection)]},
          id: transport_name
        )
      end)

    children = [
      {Registry, keys: :unique, name: Voomex.SMPP.TetherRegistry, id: Voomex.SMPP.TetherRegistry},
      {Registry,
       keys: :unique, name: Voomex.SMPP.ConnectionRegistry, id: Voomex.SMPP.ConnectionRegistry},
      {Monitor, [connections: connections]}
      | children
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
