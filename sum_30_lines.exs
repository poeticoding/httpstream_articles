"https://poeticoding-data.sfo2.digitaloceanspaces.com/httpstream/numbers.txt"
|> HTTPStream.get()
|> HTTPStream.lines()
|> Stream.map(fn line-> 
	case Integer.parse(line) do
		{num, _} -> num
		:error -> 0
	end
end)

|> Enum.take(30)

|> Enum.sum()
|> IO.puts()
