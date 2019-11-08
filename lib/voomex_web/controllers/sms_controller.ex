defmodule VoomexWeb.FooController do
  use VoomexWeb, :controller

  def send(conn, params) do
    # send a message to MNO
    # FIXME: just echo the params back for now
    json(conn, params)
  end
end
