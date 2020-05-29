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

    test "returns multiple PDUs if multiple parts present" do
      connection = %Connection{}
      pdu_list = PDU.submit_sm(connection, "19195551212", ["Test", " message"])

      assert length(pdu_list) == 2

      for pdu <- pdu_list do
        assert pdu.mandatory.esm_class == 0x40
      end
    end
  end
end
