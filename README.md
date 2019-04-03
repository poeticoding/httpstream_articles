# HTTPStream

Wouldn’t be great to process a large HTTP response, in chunks, with Elixir streams? 

```
HTTPStream.get("https://.../large_image.tiff")
|> StreamGzip.gzip
|> Stream.into(File.stream!("image.tiff.gz"))
|> Stream.run
```
Or process a huge remote text files line by line, on the fly?

```
"https://.../numbers.txt"
|> HTTPStream.get()
|> HTTPStream.lines()
|> Stream.map(...)
|> Enum.sum()
```

In these two articles we see how to build an Elixir Stream around a HTTPoison async response so we can take advantage of streams lazyness and composability.


* [Part 1 - Elixir Stream to process large HTTP responses on the fly](https://www.poeticoding.com/elixir-streams-to-process-large-http-responses-on-the-fly/)
* [Part 2 - Elixir Stream and large HTTP responses: processing text](https://www.poeticoding.com/elixir-stream-and-large-http-responses-processing-text/)

 
This code is just meant as an experiment and it's not intended to be used in production!