defmodule CDP.Client do
  use WebSockex

  def start_link(ws_url) do
    # Connect to Chromium's WebSocket debugger
    WebSockex.start_link(ws_url, __MODULE__, %{next_id: 1, callers: %{}})
  end

  def send_command(pid, method, params \\ %{}) do
    # Send command via message, then block until response arrives
    send(pid, {:send_command, self(), method, params})

    receive do
      response -> response
    end
  end

  def handle_info({:send_command, caller, method, params}, state) do
    # Encode JSON-RPC message, store caller for later reply
    id = state.next_id
    message = Jason.encode!(%{id: id, method: method, params: params})

    {:reply, {:text, message},
     %{state | next_id: id + 1, callers: Map.put(state.callers, id, caller)}}
  end

  def handle_frame({:text, raw}, state) do
    # Route incoming response to the waiting caller
    %{"id" => id} = decoded = Jason.decode!(raw)

    case decoded do
      %{"result" => result} ->
        send(Map.get(state.callers, id), {:ok, result})

      %{"error" => error} ->
        send(Map.get(state.callers, id), {:error, error})
    end

    {:ok, %{state | callers: Map.delete(state.callers, id)}}
  end
end
