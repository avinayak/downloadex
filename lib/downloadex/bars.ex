defmodule Downloadex.Bars do
  alias Downloadex.DownloadableFile

  @bar_width_default 50

  def render_bars(downloadables, char_empty \\ "_", char_full \\ "#") do
    bar_width =
      case :io.columns() do
        {:ok, width} ->
          div(width, 4)

        {:error, _} ->
          @bar_width_default
      end

    url_width = div(bar_width, 2)


    downloadables
    |> Map.values()
    |> Enum.map(fn %DownloadableFile{url: url, size: size, downloaded: downloaded} ->
      fraction = downloaded / size
      url_len = String.length(url)
      percentage =
        ((fraction * 100) |> :erlang.float_to_binary(decimals: 1) |> String.pad_leading(5)) <>
          " %"

      percentage <>
        bar(fraction, char_empty, char_full, bar_width) <>
        String.slice(url, (url_len - url_width)..url_len-1)
    end)
  end

  def bar(fraction, char_empty, char_full, bar_width) do
    full_count = (bar_width * fraction) |> trunc
    bars = String.duplicate(char_full, full_count)
    voids = String.duplicate(char_empty, bar_width - full_count + 1)
    "|#{bars <> voids}|"
  end
end
