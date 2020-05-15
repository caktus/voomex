defmodule Voomex.SMPP.WorkerTest do
  use ExUnit.Case

  alias Voomex.SMPP.Worker

  describe "sending a message" do
    test "successfully" do
      Worker.perform(%{
        "dest_addr" => "1231231234",
        "message" => "Hello",
        "mno" => "my_mno",
        "from_addr" => "10020"
      })

      assert_received {:send_submit_sm, "my_mno", "10020", pdu}

      assert pdu.mandatory.short_message == "Hello"
    end
  end
end
