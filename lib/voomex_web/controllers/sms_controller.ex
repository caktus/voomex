defmodule VoomexWeb.SMSController do
  use VoomexWeb, :controller

  def send(conn, %{"data" => %{"to_addr" => to_addr, "content" => content}}) do
    # send a message to MNO

    # to_addr is a list of phone numbers
    case Enum.each(to_addr, fn dest_addr ->
           Voomex.SMPP.send_to_mno(dest_addr, content)
         end) do
      :ok -> json(conn, :ok)
      _ -> json(conn, "error")
    end
  end
end
