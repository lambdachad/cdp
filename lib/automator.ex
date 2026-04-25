defmodule Automator do
  @moduledoc """
  Chrome DevTools Protocol (CDP) scraper for Elixir.

  Spawn headless Chromium, navigate pages, evaluate JavaScript, and extract data
  through a clean, idiomatic Elixir API.

  ## Quick Start

      # Start a scraper (spawns Chromium + connects automatically)
      {:ok, scraper} = Automator.Scraper.start_link()

      # Navigate to a page
      Automator.Scraper.navigate(scraper, "https://example.com")

      # Evaluate JavaScript
      title = Automator.Scraper.eval(scraper, "document.title")
      # => "Example Domain"

      # Wait for an element to appear
      Automator.Scraper.wait_for_selector(scraper, "h1")

      # Click an element
      Automator.Scraper.click(scraper, "a")

      # Take a screenshot
      %{"data" => base64} = Automator.Scraper.screenshot(scraper)
      File.write!("page.png", Base.decode64!(base64))

      # Cleanup
      Automator.Scraper.stop(scraper)

  ## Architecture

  Automator has three layers, from high-level to low-level:

      ┌─────────────────────────────────────────┐
      │  Automator.Scraper  (GenServer)         │  ← Primary API
      │  Manages browser + page, simple fns     │
      ├─────────────────────────────────────────┤
      │  Automator.Client   (WebSockex)         │  ← Raw CDP commands
      │  WebSocket JSON-RPC client              │
      ├─────────────────────────────────────────┤
      │  Automator.Chromium (Process mgmt)      │  ← Browser lifecycle
      │  Spawns/kills headless Chromium         │
      └─────────────────────────────────────────┘

  Most users only need `Automator.Scraper`. Use `Client` when you need direct
  access to CDP domains not exposed by the scraper. Use `Chromium` when you want
  to manage the browser lifecycle yourself.

  ## Modules

    * `Automator.Scraper` — High-level scraping API. Manages a Chromium instance
      and page connection. Provides `navigate/2`, `eval/2`, `click/2`,
      `wait_for_selector/3`, `screenshot/1`, `set_cookie/4`, and `stop/1`.

    * `Automator.Chromium` — Low-level browser process management. Spawns and
      kills headless Chromium instances.

    * `Automator.Client` — Low-level WebSocket client for sending raw CDP
      commands. Use this for direct access to any Chrome DevTools Protocol method.

  ## Requirements

  Requires Chromium installed and available on PATH as `chromium`.

  ## Installation

  Add `:automator` to your dependencies:

      def deps do
        [
          {:automator, "~> 0.1.0"}
        ]
      end

  """
end
