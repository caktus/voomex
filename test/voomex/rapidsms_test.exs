defmodule Voomex.RapidSMS.Test do
  use ExUnit.Case

  alias Voomex.RapidSMS

  describe "pdu_to_request" do
    test "sets expected values" do
      pdu = %{
        mandatory: %{
          source_addr: "12345",
          destination_addr: "54321",
          short_message: "Test message"
        }
      }

      request = RapidSMS.pdu_to_request(pdu)

      assert request.from_addr == "12345"
      assert request.to_addr == "54321"
      assert request.content == "Test message"
    end
  end
end
