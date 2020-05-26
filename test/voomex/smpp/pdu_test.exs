defmodule Voomex.SMPP.PDUTest do
  use ExUnit.Case

  alias Voomex.SMPP.PDU

  describe "submit message" do
    test "sets the destination and message" do
      pdu = PDU.submit_sm("10020", "19195551212", "Test message")

      assert pdu.mandatory.destination_addr == "19195551212"
      assert pdu.mandatory.short_message == "Test message"
    end

    test "sets the source" do
      pdu = PDU.submit_sm("10020", "19195551212", "Test message")

      assert pdu.mandatory.source_addr == "10020"
      assert pdu.mandatory.source_addr_ton == 1
      assert pdu.mandatory.source_addr_npi == 1
    end
  end
end
