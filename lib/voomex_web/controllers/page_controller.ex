defmodule VoomexWeb.PageController do
  use VoomexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
