defmodule Voomex.Repo do
  use Ecto.Repo,
    otp_app: :voomex,
    adapter: Ecto.Adapters.Postgres
end
