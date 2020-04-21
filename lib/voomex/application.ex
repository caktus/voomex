defmodule Voomex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      VoomexWeb.Endpoint,
      smpp_listener()
    ]

    children = Enum.reject(children, &is_nil/1)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Voomex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    VoomexWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def smpp_listener() do
    config = Application.get_env(:voomex, Voomex.SMPP)

    case config[:start] do
      true ->
        Voomex.SMPP.Connection

      false ->
        nil
    end
  end
end
