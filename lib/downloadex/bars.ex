defmodule Downloadex.Bars do
  alias Downloadex.{DownloadableFile, Utils}

  @bar_width_default 50

  def render_bars(downloadables, char_empty \\ "_", char_full \\ "#") do
    columns_size =
      case :io.columns() do
        {:ok, width} ->
          width

        {:error, _} ->
          @bar_width_default
      end

    bar_width = div(columns_size, 4)

    downloadables
    |> Map.values()
    |> Enum.map(fn %DownloadableFile{url: url, size: size, downloaded: downloaded} ->
      fraction = downloaded / size
      filename = Utils.get_url_filename(url)

      percentage =
        ((fraction * 100) |> :erlang.float_to_binary(decimals: 1) |> String.pad_leading(10)) <>
          " %"

      line =
        percentage <>
          bar(fraction, char_empty, char_full, bar_width) <> filename

      if columns_size > String.length(line) do
        line <> String.duplicate(" ", columns_size - String.length(line) -1)
      else
        line
      end
    end)
  end

  def bar(fraction, char_empty, char_full, bar_width) do
    full_count = (bar_width * fraction) |> trunc
    bars = String.duplicate(char_full, full_count)
    voids = String.duplicate(char_empty, bar_width - full_count)
    "|#{bars <> voids}|"
  end
end
