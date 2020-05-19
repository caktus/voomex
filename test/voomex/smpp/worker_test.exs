defmodule Voomex.SMPP.WorkerTest do
  use ExUnit.Case

  alias Voomex.SMPP.Worker

  describe "sending a message" do
    test "successfully" do
      Worker.perform(%{
        "dest_addr" => "19195551212",
        "message" => "Hello",
        "mno" => "libyana",
        "from_addr" => "10020"
      })

      assert_received {:send_submit_sm, "libyana", "10020", pdu}

      assert pdu.mandatory.short_message == "Hello"
    end
  end
end
