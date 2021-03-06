defmodule Voomex.RapidSMS.Worker do
  @moduledoc """
  Oban worker for messages going to RapidSMS
  """

  use Oban.Worker, queue: :to_rapidsms

  @impl true
  def perform(args, _job), do: perform(args)

  def perform(args) do
    request_body =
      args
      |> Voomex.RapidSMS.prepare_body()
      |> Jason.encode!()

    Mojito.post(args["url"], [{"content-type", "application/json"}], request_body)
  end
end
