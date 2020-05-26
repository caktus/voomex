defmodule Voomex.SMPP.Worker do
  @moduledoc """
  Oban worker for messages going to SMPP connection
  """

  use Oban.Worker, queue: :to_smpp

  alias Voomex.SMPP
  alias Voomex.SMPP.PDU

  @impl true
  def perform(args, _job), do: perform(args)

  def perform(%{
        "dest_addr" => dest_addr,
        "message" => message,
        "mno" => mno,
        "from_addr" => from_addr
      }) do
    submit_sm = PDU.submit_sm(from_addr, dest_addr, message)

    SMPP.send_submit_sm(mno, from_addr, submit_sm)
  end
end
