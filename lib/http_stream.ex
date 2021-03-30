defmodule HTTPStream do
  def get(url) do
    Stream.resource(start_fun(url), &next_fun/1, &end_fun/1)
  end

  defp start_fun(url) do
    fn -> HTTPoison.get!(url, %{}, stream_to: self(), async: :once) end
  end
  defp next_fun(%HTTPoison.AsyncResponse{} = resp), do: handle_async_resp(resp)
  defp end_fun(%HTTPoison.AsyncResponse{id: id}), do: :hackney.stop_async(id)

  defp handle_async_resp(%HTTPoison.AsyncResponse{id: id} = resp) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: _code} ->
        # IO.inspect(code, label: "STATUS: ")
        HTTPoison.stream_next(resp)
        {[], resp}

      %HTTPoison.AsyncHeaders{id: ^id, headers: _headers} ->
        # IO.inspect(headers, label: "HEADERS: ")
        HTTPoison.stream_next(resp)
        {[], resp}

      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        HTTPoison.stream_next(resp)
        # :erlang.garbage_collect()
        {[chunk], resp}

      %HTTPoison.AsyncEnd{id: ^id} ->
          {[:end], resp}
    after
      30_000 -> raise "receive timeout"
    end
  end

  def lines(enum), do:
    enum
    |> Stream.flat_map(&split_if_apply/1) # case the chunk already contains more than one line
    |> Stream.map(fn chunk -> [chunk] end)
    |> Stream.transform("", &accumulate_or_emmit/2)

  def accumulate_or_emmit([:end], acc), do: {:halt, acc}
  def accumulate_or_emmit("\n", acc), do: {:halt, acc}
  def accumulate_or_emmit([i], acc), do: {[i], acc <> i}

  def split_if_apply(:end), do: [:end]
  def split_if_apply(str), do: Regex.split(~r/(?<=\n)/, str, trim: true)

end
