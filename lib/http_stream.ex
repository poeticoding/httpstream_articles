defmodule HTTPStream do

  def get(url,emit_end\\false) do

    Stream.resource(
      fn -> start_fun(url) end,

      # next_fun (multi caluses)
      fn 
        %HTTPoison.AsyncResponse{}=resp ->
          handle_async_resp(resp,emit_end)

        #last accumulator when emitting :end
        {:end, resp}->
          {:halt, resp}
      end,
      
      fn %HTTPoison.AsyncResponse{id: id} ->
        IO.puts("END_FUN")
        :hackney.stop_async(id)
      end
    )
  end


  defp start_fun(url) do
    HTTPoison.get!(url,%{}, [stream_to: self(), async: :once])
  end


  defp handle_async_resp(%HTTPoison.AsyncResponse{id: id}=resp,emit_end) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code}->
        IO.inspect(code, label: "STATUS: ")
        HTTPoison.stream_next(resp)
        {[], resp}
      %HTTPoison.AsyncHeaders{id: ^id, headers: headers}->
        IO.inspect(headers, label: "HEADERS: ")
        HTTPoison.stream_next(resp)
        {[], resp}
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk}->
        HTTPoison.stream_next(resp)
        # :erlang.garbage_collect()
        {[chunk], resp}
      %HTTPoison.AsyncEnd{id: ^id}->
        if emit_end do
          {[:end], {:end, resp}}  
        else
          {:halt, resp}
        end
    after
      5_000 -> raise "receive timeout"
    end
  end

  def lines(enum), do: lines(enum, :string_split)

  def lines(enum, :next_lines) do
    enum
    |> Stream.transform("",&next_lines/2)
  end

  def lines(enum, :string_split) do
    enum
    |> Stream.transform("",fn 
      :end, acc -> 
        {[acc],""}
      chunk, acc ->
        [last_line | lines] = 
          String.split(acc <> chunk,"\n")
          |> Enum.reverse()
        {Enum.reverse(lines),last_line}
    end)
  end


  defp next_lines(:end,prev), do: {[prev], ""}
  defp next_lines(chunk,current_line) do
    # :erlang.garbage_collect()
    next_lines(chunk,current_line,[])
  end

  defp next_lines(<<"\n"::utf8, rest::binary>>,current_line,lines) do
    next_lines(rest,"",[current_line <> "\n" | lines])  
  end

  defp next_lines(<<c::utf8, rest::binary>>,current_line,lines) do
    next_lines(rest,<<current_line::binary, c::utf8>>,lines)
  end
    
  defp next_lines(<<>>,current_line,lines) do
    {Enum.reverse(lines), current_line}
  end


end
