defmodule HttpStreamTest do
  use ExUnit.Case
  use Assertions.Case

  test "emit line without \\n" do
    content = """
    1
    """

    bypass = mock_request(content)

    response =
      HTTPStream.get("http://localhost:#{bypass.port}/")
      |> HTTPStream.lines()
      |> Enum.to_list()

    assert_lists_equal(["1\n"], response)
  end

  test "emit multiple lines in on chunk" do
    content = """
    1
    2
    3
    """

    bypass = mock_request(content)

    response =
      HTTPStream.get("http://localhost:#{bypass.port}/")
      |> HTTPStream.lines()
      |> Enum.to_list()

    assert_lists_equal(["1\n", "2\n", "3\n"], response)
  end

  defp mock_request(content) do
    bypass = Bypass.open()

    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, content)
    end)

    bypass
  end
end
