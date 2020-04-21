defmodule VoomexWeb.SMSController do
  use VoomexWeb, :controller

  alias Voomex.SMPP

  def send(conn, %{"data" => %{"to_addr" => to_addr, "content" => content}})
      when is_list(to_addr) do
    SMPP.send_to_mno(to_addr, content)

    json(conn, :ok)
  end

  def send(conn, _params) do
    conn
    |> put_status(422)
    |> json("error")
  end
end
