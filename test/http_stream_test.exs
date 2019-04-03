defmodule HTTPStreamTest do
  use ExUnit.Case
  doctest HTTPStream

  test "greets the world" do
    assert HTTPStream.hello() == :world
  end
end
