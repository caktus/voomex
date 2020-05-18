defmodule Voomex.RapidSMS.Test do
  use ExUnit.Case

  alias Voomex.RapidSMS

  describe "parse_pdu" do
    test "gets expected values from pdu" do
      pdu = %{
        mandatory: %{
          source_addr: "19195551212",
          destination_addr: "10020",
          short_message: "Test message"
        }
      }

      request = RapidSMS.parse_pdu(pdu)

      assert request.from_addr == "19195551212"
      assert request.to_addr == "10020"
      assert request.content == "Test message"
    end
  end

  describe "prepare_body" do
    test "returns the expected values" do
      args = %{
        "content" => "Test message",
        "from_addr" => "19195551212",
        "to_addr" => "10020",
        "mno" => "almadar"
      }

      body = RapidSMS.prepare_body(args)

      assert body.content == "Test message"
      assert body.from_addr == "19195551212"
      assert body.to_addr == "10020"
      assert body.transport_name == "almadar_smpp_transport_10020"
    end
  end

  describe "get_url" do
    test "returns RapidSMS URL from config" do
      url = RapidSMS.get_url("almadar")

      assert url == "http://localhost:8002/backend/vumi-almadar/"
    end

    test "returns nil for nonexistent MNO" do
      url = RapidSMS.get_url("i_dont_exist")

      assert url == nil
    end
  end
end
