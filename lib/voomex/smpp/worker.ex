defmodule Voomex.SMPP.Worker do
  @moduledoc """
  Oban worker for messages going to SMPP connection
  """

  use Oban.Worker, queue: :to_smpp

  alias Voomex.SMPP
  alias Voomex.SMPP.PDU

  @impl true
  def perform(args, _job), do: perform(args)

  def perform(%{"dest_addr" => dest_addr, "message" => message}) do
    submit_sm = PDU.submit_sm(dest_addr, message)

    # TODO validate what comes back from this, raise an error if there is one
    SMPP.send_submit_sm(submit_sm)
  end
end
