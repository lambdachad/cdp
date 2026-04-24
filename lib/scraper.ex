defmodule CDP.Scraper do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    browser = CDP.Chromium.spawn()
    {:ok, %{body: targets}} = Req.get("http://localhost:#{browser.port}/json")

    page_ws_url =
      targets |> Enum.find(fn t -> t["type"] == "page" end) |> Map.fetch!("webSocketDebuggerUrl")

    {:ok, client} = CDP.Client.start_link(page_ws_url)
    {:ok, %{browser: browser, client: client}}
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def handle_call({:navigate, url}, _from, %{client: client} = state) do
    {:ok, result} = CDP.Client.send_command(client, "Page.navigate", %{url: url})
    :timer.sleep(1000)
    {:reply, result, state}
  end

  def handle_call({:eval, js}, _from, %{client: client} = state) do
    {:ok, result} =
      CDP.Client.send_command(client, "Runtime.evaluate", %{
        expression: js,
        awaitPromise: true,
        returnByValue: true
      })

    value = result["result"]["value"]
    {:reply, value, state}
  end

  def handle_call({:set_cookie, name, value, domain}, _from, %{client: client} = state) do
    {:ok, result} =
      CDP.Client.send_command(client, "Network.setCookie", %{
        name: name,
        value: value,
        domain: domain
      })

    {:reply, result, state}
  end

  def handle_call({:screenshot}, _from, %{client: client} = state) do
    {:ok, result} = CDP.Client.send_command(client, "Page.captureScreenshot")
    {:reply, result, state}
  end

  def handle_call({:wait_for_selector, selector, timeout}, _from, %{client: client} = state) do
    {:ok, result} =
      CDP.Client.send_command(client, "Runtime.evaluate", %{
        expression: """
        new Promise((resolve, reject) => {
          const el = document.querySelector('#{selector}');
          if (el) return resolve(true);
          const observer = new MutationObserver(() => {
            if (document.querySelector('#{selector}')) {
              observer.disconnect();
              resolve(true);
            }
          });
          observer.observe(document, {childList: true, subtree: true});
          setTimeout(() => { observer.disconnect(); reject(new Error('timeout')); }, #{timeout});
        })
        """,
        awaitPromise: true,
        returnByValue: true
      })

    case result["result"]["type"] do
      "boolean" -> {:reply, :ok, state}
      "object" -> {:reply, {:error, "selector #{selector} not found within #{timeout}ms"}, state}
    end
  end

  def handle_call({:click, selector}, _from, %{client: client} = state) do
    {:ok, result} =
      CDP.Client.send_command(client, "Runtime.evaluate", %{
        expression: """
        (() => {
          const el = document.querySelector('#{selector}');
          if (el) { el.click(); return true; }
          return false;
        })()
        """,
        returnByValue: true
      })

    {:reply, result["result"]["value"], state}
  end

  def handle_call(:stop, _from, %{browser: browser} = state) do
    CDP.Chromium.kill(browser)
    {:stop, :normal, :ok, state}
  end

  def navigate(pid, url) do
    GenServer.call(pid, {:navigate, url})
  end

  def eval(pid, js) do
    GenServer.call(pid, {:eval, js})
  end

  def set_cookie(pid, name, value, domain) do
    GenServer.call(pid, {:set_cookie, name, value, domain})
  end

  def screenshot(pid) do
    GenServer.call(pid, {:screenshot})
  end

  def wait_for_selector(pid, selector, timeout \\ 10_000) do
    GenServer.call(pid, {:wait_for_selector, selector, timeout})
  end

  def click(pid, selector) do
    GenServer.call(pid, {:click, selector})
  end
end
