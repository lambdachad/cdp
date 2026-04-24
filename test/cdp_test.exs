defmodule CDP.ChromiumTest do
  use ExUnit.Case

  test "spawn returns chromium port and ws_url" do
    browser = CDP.Chromium.spawn()
    on_exit(fn -> CDP.Chromium.kill(browser) end)

    assert is_port(browser.chromium)
    assert String.starts_with?(browser.ws_url, "ws://")
  end
end

defmodule CDP.ClientTest do
  use ExUnit.Case

  setup do
    browser = CDP.Chromium.spawn()
    {:ok, client} = CDP.Client.start_link(browser.ws_url)
    on_exit(fn -> CDP.Chromium.kill(browser) end)
    %{browser: browser, client: client}
  end

  test "send_command returns browser version", %{client: client} do
    {:ok, result} = CDP.Client.send_command(client, "Browser.getVersion")

    assert result["product"] =~ "Chrome"
    assert result["protocolVersion"]
  end

  test "send_command with params works", %{client: client} do
    {:ok, result} =
      CDP.Client.send_command(client, "Browser.setDownloadBehavior", %{
        behavior: "allow",
        downloadPath: "/tmp"
      })

    assert result == %{}
  end
end
