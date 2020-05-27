defmodule Voomex.SMPP.WorkerTest do
  use ExUnit.Case

  alias Voomex.SMPP.Worker

  describe "sending a message" do
    test "successfully" do
      Worker.perform(%{
        "dest_addr" => "19195551212",
        "message" => "Hello",
        "mno" => "libyana",
        "source_addr" => "10020"
      })

      assert_received {:send_submit_sm, "libyana", "10020", "19195551212", "Hello"}
    end
  end
end
