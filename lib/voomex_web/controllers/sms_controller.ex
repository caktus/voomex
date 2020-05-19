defmodule VoomexWeb.SMSController do
  use VoomexWeb, :controller

  alias Voomex.SMPP

  def send(conn, %{
        "to_addr" => to_addr,
        "content" => content,
        "mno" => mno,
        "from_addr" => from_addr
      })
      when is_list(to_addr) do
    # NOTE: may also need "in_reply_to" and "metadata.rapidsms_msg_id"
    SMPP.send_to_mno(mno, from_addr, to_addr, content)

    json(conn, :ok)
  end

  def send(conn, _params) do
    conn
    |> put_status(422)
    |> json("error")
  end
end
