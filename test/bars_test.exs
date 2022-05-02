defmodule Downloadex.BarsTest do
  use ExUnit.Case

  alias Downloadex.{Bars, DownloadableFile}

  test "Queue" do
    downloads = [
      %DownloadableFile{
        url: "http://example.com/file1.txt",
        size: 200,
        downloaded: 45
      },
      %DownloadableFile{
        url: "http://example.com/file2.txt",
        size: 150,
        downloaded: 15
      }
    ]

    assert Bars.render_bars(downloads) == [
             "22.5 %|###########_______________________________________|http://example.com/fi",
             "10.0 %|#####_____________________________________________|http://example.com/fi"
           ]
  end
end
