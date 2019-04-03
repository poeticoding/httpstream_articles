:observer.start
:timer.sleep 5_000
IO.puts("starting...")

"https://poeticoding-data.sfo2.digitaloceanspaces.com/httpstream/numbers.txt"

|> HTTPStream.get(true) #emit_end = true
|> HTTPStream.lines()



|> Stream.map(fn line -> 
	case Integer.parse(line) do
		{num, _} -> num
		:error -> 0
	end
end)
|> Enum.sum()
|> IO.puts()