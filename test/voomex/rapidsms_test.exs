defmodule Voomex.RapidSMS.Test do
  use ExUnit.Case

  alias Voomex.RapidSMS

  describe "prepare request" do
    test "sets from_addr" do
      pdu = %{
        mandatory: %{
          source_addr: "12345",
          destination_addr: "54321",
          short_message: "Test message"
        }
      }

      request = RapidSMS.pdu_to_request(pdu)

      assert request.from_addr == "12345"
    end
  end
end
