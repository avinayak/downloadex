defmodule Downloadex.BarsTest do
  use ExUnit.Case

  alias Downloadex.{Bars, DownloadableFile}

  test "bars render correctly" do
    downloads = %{
      0 => %DownloadableFile{
        url: "http://example.com/file1.txt",
        size: 200,
        downloaded: 45
      },
      1 => %DownloadableFile{
        url: "http://example.com/file2.txt",
        size: 150,
        downloaded: 15
      }
    }

    assert Bars.render_bars(downloads) == [
             "      22.5 %|##__________|file1.txt              ",
             "      10.0 %|#___________|file2.txt              "
           ]
  end

  test "bar renders correctly" do
    assert Bars.bar(0.5, "_", "#", 10) == "|#####_____|"
    assert Bars.bar(0.0, "_", "#", 10) == "|__________|"
    assert Bars.bar(1.0, "_", "#", 10) == "|##########|"
    assert Bars.bar(0.5, " ", ".", 10) == "|.....     |"
  end
end
