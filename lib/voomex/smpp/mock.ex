defmodule Voomex.SMPP.Mock do
  @moduledoc """
  Mock implementation for the SMPP client
  """

  @behaviour Voomex.SMPP

  @impl true
  def send_submit_sm(mno, from_addr, submit_sm) do
    send(self(), {:send_submit_sm, mno, from_addr, submit_sm})
  end

  @impl true
  def send_to_mno(mno, from_addr, dest_addr, message) do
    send(self(), {:send_to_mno, mno, from_addr, dest_addr, message})
  end
end
