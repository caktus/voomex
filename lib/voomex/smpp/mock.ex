defmodule Voomex.SMPP.Mock do
  @moduledoc """
  Mock implementation for the SMPP client
  """

  @behaviour Voomex.SMPP

  @impl true
  def send_to_mno(dest_addr, message) do
    send(self(), {:send_to_mno, dest_addr, message})
  end
end
