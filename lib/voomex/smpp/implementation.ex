defmodule Voomex.SMPP.Implementation do
  @moduledoc """
  Real implementation for the SMPP client
  """

  @behaviour Voomex.SMPP

  @impl true
  def send_to_mno(dest_addresses, message) do
    %{dest_addresses: dest_addresses, message: message}
    |> Voomex.SMPP.Worker.new()
    |> Oban.insert()
  end
end
