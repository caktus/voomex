defmodule VoomexWeb.Router do
  use VoomexWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VoomexWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/health", PageController, :health
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", VoomexWeb do
    pipe_through :api

    # named 'rapidsms' to match the current libya elections set up
    post "/rapidsms/:mno", SMSController, :send
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: Voomex.Telemetry
    end
  end
end
