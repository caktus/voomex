defmodule Voomex.SMPP.WorkerTest do
  use ExUnit.Case

  alias Voomex.SMPP.Worker

  describe "sending a message" do
    test "successfully" do
      Worker.perform(%{"dest_addr" => "1231231234", "message" => "Hello"})

      assert_received {:send_submit_sm, pdu}

      assert pdu.mandatory.short_message == "Hello"
    end
  end
end
