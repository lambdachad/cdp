# CDP

Chrome DevTools Protocol scraper for Elixir. Spawn headless Chromium, navigate pages, evaluate JavaScript, and extract data.

## Installation

Add `:cdp` to your dependencies:

```elixir
def deps do
  [
    {:cdp, "~> 0.1.0"}
  ]
end
```

Requires Chromium installed and available on PATH as `chromium`.

## Quick Start

```elixir
# Start a scraper (spawns Chromium + connects automatically)
{:ok, scraper} = CDP.Scraper.start_link()

# Navigate to a page
CDP.Scraper.navigate(scraper, "https://example.com")

# Evaluate JavaScript
title = CDP.Scraper.eval(scraper, "document.title")
# => "Example Domain"

# Wait for an element to appear
CDP.Scraper.wait_for_selector(scraper, "h1")

# Click an element
CDP.Scraper.click(scraper, "a")

# Take a screenshot (returns base64)
%{"data" => base64} = CDP.Scraper.screenshot(scraper)

# Set cookies
CDP.Scraper.set_cookie(scraper, "name", "value", ".example.com")

# Cleanup
CDP.Scraper.stop(scraper)
```

## API

### CDP.Scraper

High-level API that manages a Chromium instance and page connection.

| Function | Description |
|----------|-------------|
| `start_link/0` | Spawn Chromium and connect to a page |
| `navigate/2` | Navigate to URL, waits ~1s for load |
| `eval/2` | Evaluate JavaScript, returns the result value |
| `click/2` | Click element by CSS selector |
| `wait_for_selector/3` | Wait for element to appear (default 10s timeout) |
| `screenshot/1` | Capture page screenshot as base64 |
| `set_cookie/4` | Set a cookie (name, value, domain) |
| `stop/1` | Kill Chromium and cleanup |

### CDP.Chromium

Low-level Chromium process management.

```elixir
browser = CDP.Chromium.spawn()
# => %{chromium: #Port<...>, os_pid: 1234, port: 9222, ws_url: "ws://..."}

CDP.Chromium.kill(browser)
```

### CDP.Client

Low-level CDP WebSocket client for sending raw commands.

```elixir
{:ok, client} = CDP.Client.start_link(ws_url)
{:ok, result} = CDP.Client.send_command(client, "Browser.getVersion")
```

## License

MIT
