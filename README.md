# Downloadex

An Elixir library to download large amounts of file in parallel.

![Demo](https://github.com/avinayak/downloadex/blob/master/downloadex.gif?raw=true)

## Installation

Adding `downloadex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:downloadex, "~> 0.1.0"}
  ]
end
```

## Usage

```
Downloadex.download(
      ["https://example.com/test1.jpg", "https://example.com/test2.jpg"],
      "./test_folder",
      4 # number of parallel workers
    )
```

## TODO

* Benchmarks
* Experiemnt with chunked downloads using Gun
* More customization
