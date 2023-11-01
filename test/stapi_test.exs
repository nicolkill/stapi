defmodule StapiTest do
  use ExUnit.Case
  doctest Stapi

  test "greets the world" do
    assert Stapi.hello() == :world
  end
end
