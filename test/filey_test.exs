defmodule FileyTest do
  use ExUnit.Case
  doctest Filey

  test "greets the world" do
    assert Filey.hello() == :world
  end
end
