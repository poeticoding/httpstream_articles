:observer.start
:timer.sleep 5_000
IO.puts("starting...")

chunk_size = 2_000

"numbers_small.txt"
|> File.stream!([],chunk_size)
|> HTTPStream.lines(:next_lines)

|> Stream.map(fn line -> 
	case Integer.parse(line) do
		{num, _} -> num
		:error -> 0
	end
end)
|> Enum.sum()
|> IO.puts()

:timer.sleep 20_000