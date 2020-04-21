defmodule Voomex.SMPP.PDUTest do
  use ExUnit.Case

  alias Voomex.SMPP.PDU

  describe "submit message" do
    test "sets the destination and message" do
      pdu = PDU.submit_sm("12345", "Test message")

      assert pdu.mandatory.destination_addr == "12345"
      assert pdu.mandatory.short_message == "Test message"
    end

    test "sets the source" do
      config = %{
        source_addr: "23456",
        source_ton: 1,
        source_npi: 1,
        dest_ton: 1,
        dest_npi: 1
      }

      pdu = PDU.submit_sm("12345", "Test message", config)

      assert pdu.mandatory.source_addr == "23456"
      assert pdu.mandatory.source_addr_ton == 1
      assert pdu.mandatory.source_addr_npi == 1
    end
  end
end
