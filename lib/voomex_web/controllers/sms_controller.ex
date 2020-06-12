defmodule VoomexWeb.SMSController do
  use VoomexWeb, :controller
  require Logger
  alias Voomex.SMPP

  def send(conn, %{
        "to_addr" => dest_addr,
        "content" => content,
        "mno" => mno,
        "from_addr" => source_addr
      })
      when is_list(dest_addr) do
    Logger.info("Message received by web API: #{source_addr}->#{dest_addr} #{mno} #{content}")
    # NOTE: may also need "in_reply_to" and "metadata.rapidsms_msg_id"
    SMPP.send_to_mno(mno, source_addr, dest_addr, content)

    json(conn, :ok)
  end

  def send(conn, _params) do
    conn
    |> put_status(422)
    |> json("error")
  end
end
