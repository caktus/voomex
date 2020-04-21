defmodule Voomex.SMPP.TetherSupervisor do
  @moduledoc """
  A tether for preventing connection failure bubble up

  Prevent the connection from tanking the entire application by
  starting a DynamicSupervisor that will always boot with no children.
  When the connection process dies enough to bubble up and kill
  this supervisor, when it restarts it will restart clean.

  The monitor process will be notified and reschedule a new connection
  child after a delay.
  """

  use DynamicSupervisor

  alias Voomex.SMPP.Connection

  @doc false
  def start_connection() do
    config = Application.get_env(:voomex, Voomex.SMPP)

    case config[:start] do
      true ->
        DynamicSupervisor.start_child(__MODULE__, {Connection, []})

      false ->
        {:error, :not_starting}
    end
  end

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
