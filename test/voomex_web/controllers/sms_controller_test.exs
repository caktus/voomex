defmodule VoomexWeb.SMSControllerTest do
  use VoomexWeb.ConnCase

  describe "sending sms messages to the network" do
    test "successful", %{conn: conn} do
      data = %{
        "to_addr" => ["19195551212", "19195553434"],
        "content" => "Hello, world",
        "from_addr" => "10020"
      }

      conn = post(conn, Routes.sms_path(conn, :send, "my_mno"), data)

      assert json_response(conn, 200) == "ok"

      assert_received {:send_to_mno, "my_mno", "10020", ["19195551212", "19195553434"],
                       "Hello, world"}
    end

    test "failure when to_addr is not a list", %{conn: conn} do
      data = %{
        "to_addr" => "19195551212",
        "content" => "Hello, world",
        "from_addr" => "10020"
      }

      conn = post(conn, Routes.sms_path(conn, :send, "my_mno"), data)

      assert json_response(conn, 422) == "error"
    end

    test "failure when missing parameters", %{conn: conn} do
      conn = post(conn, Routes.sms_path(conn, :send, "my_mno"), %{})

      assert json_response(conn, 422) == "error"
    end
  end
end
