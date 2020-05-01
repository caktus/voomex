defmodule Voomex.RapidSMS.Worker do
  @moduledoc """
  Oban worker for messages going to RapidSMS
  """

  use Oban.Worker, queue: :to_rapidsms

  alias Voomex.RapidSMS

  @impl true
  def perform(args, _job), do: perform(args)

  def perform(args) do
    args
    |> Jason.encode!()
    |> RapidSMS.post_request()
  end
end
