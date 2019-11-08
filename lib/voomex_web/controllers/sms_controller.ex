defmodule VoomexWeb.SMSController do
  use VoomexWeb, :controller

  def send(conn, params) do
    # send a message to MNO
    # ... just echo the params back for now
    json(conn, params)
  end
end
