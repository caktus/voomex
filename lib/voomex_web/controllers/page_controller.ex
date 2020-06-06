defmodule VoomexWeb.PageController do
  use VoomexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def health(conn, _params) do
    send_resp(conn, 200, "Voomex is healthy")
  end
end
