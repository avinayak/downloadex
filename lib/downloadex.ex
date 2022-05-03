defmodule Downloadex do
  @moduledoc """
  Documentation for `Downloadex`.
  """

  @user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.0.0 Safari/537.36"

  @default_headers [
    {"User-Agent", @user_agent},
    {"Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"},
    {"Accept-Language", "en-US,en;q=0.5"},
    {"DNT", "1"},
    {"Upgrade-Insecure-Requests", "1"},
    {"Connection", "keep-alive"}
  ]

  def download(urls, path, n_workers, headers \\ @default_headers) do
    {:ok, pid} = Downloadex.Scheduler.start_link({urls, path, n_workers, headers})

    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, _, _, _} ->
        true
    end
  end
end
