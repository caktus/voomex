defmodule VoomexWeb.SMSControllerTest do
  use VoomexWeb.ConnCase

  describe "sending sms messages to the network" do
    test "successful", %{conn: conn} do
      data = %{
        "to_addr" => ["12345", "23456"],
        "content" => "Hello, world"
      }

      conn = post(conn, Routes.sms_path(conn, :send), data)

      assert json_response(conn, 200) == "ok"

      assert_received {:send_to_mno, ["12345", "23456"], "Hello, world"}
    end

    test "failure when to_addr is not a list", %{conn: conn} do
      data = %{
        "to_addr" => "12345",
        "content" => "Hello, world"
      }

      conn = post(conn, Routes.sms_path(conn, :send), data)

      assert json_response(conn, 422) == "error"
    end

    test "failure when missing parameters", %{conn: conn} do
      conn = post(conn, Routes.sms_path(conn, :send), %{})

      assert json_response(conn, 422) == "error"
    end
  end
end
