chunk_stream = File.stream!("numbers_small.txt",[],2000)
lines_stream = File.stream!("numbers_small.txt", [], :line)

# function to conver the lines to integers
# and sum the numbers
stream_sum = fn enum ->
  enum
  |> Stream.map(fn line-> 
		case Integer.parse(line) do
			{num, _} -> num
			:error -> 0
		end
	end)
	|> Enum.sum()
end


Benchee.run(%{
	"File.stream! :line" => fn ->
		lines_stream 
		|> stream_sum.()
	end,
	"with next_lines" => fn ->
		chunk_stream
		|> HTTPStream.lines(:next_lines)
		|> stream_sum.()
	end,
	"with String.split" => fn ->
		chunk_stream
		|> HTTPStream.lines(:string_split)
		|> stream_sum.()
	end
},
  time: 10
)