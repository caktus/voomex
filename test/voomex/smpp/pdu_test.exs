defmodule Voomex.SMPP.PDUTest do
  use ExUnit.Case

  alias Voomex.SMPP.{Connection, PDU}

  describe "submit message" do
    test "sets the destination and message" do
      connection = %Connection{}
      pdu = PDU.submit_sm(connection, "19195551212", "Test message")

      assert pdu.mandatory.destination_addr == "19195551212"
      assert pdu.mandatory.short_message == "Test message"
    end

    test "sets the source" do
      connection = %Connection{source_addr: "10021", source_ton: 2, source_npi: 3}
      pdu = PDU.submit_sm(connection, "19195551212", "Test message")

      assert pdu.mandatory.source_addr == "10021"
      assert pdu.mandatory.source_addr_ton == 2
      assert pdu.mandatory.source_addr_npi == 3
    end
  end
end
