defmodule Voomex.SMPP.Worker do
  @moduledoc """
  Oban worker for messages going to SMPP connection
  """

  use Oban.Worker, queue: :to_smpp

  alias Voomex.SMPP

  @impl true
  def perform(args, _job), do: perform(args)

  def perform(%{
        "dest_addr" => dest_addr,
        "message" => message,
        "mno" => mno,
        "source_addr" => source_addr
      }) do
    SMPP.send_submit_sm(mno, source_addr, dest_addr, message)
  end
end
