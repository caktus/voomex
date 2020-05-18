defmodule Voomex.RapidSMS.Test do
  use ExUnit.Case

  alias Voomex.RapidSMS

  describe "parse_pdu" do
    test "gets expected values from pdu" do
      pdu = %{
        mandatory: %{
          source_addr: "12345",
          destination_addr: "54321",
          short_message: "Test message"
        }
      }

      request = RapidSMS.parse_pdu(pdu)

      assert request.from_addr == "12345"
      assert request.to_addr == "54321"
      assert request.content == "Test message"
    end
  end
end
