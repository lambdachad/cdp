defmodule CDPTest do
  use ExUnit.Case
  doctest CDP

  test "greets the world" do
    assert CDP.hello() == :world
  end
end
