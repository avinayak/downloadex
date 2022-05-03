defmodule Downloadex do
  @moduledoc """
  Downloadex is a library to download large number of files in parallel.
  """

  @doc """
    downloads a list of urls to a given directory in parallel.

  ## Examples

      iex> Downloadex.download(
        [ "https://example.com/file1.txt",
          "https://example.com/file2.txt",
          "https://example.com/file3.txt",
          "https://example.com/file4.txt"],
        "./images",
        3 # number of parallel downloads
      )
      :ok

  """
  def download(
        urls,
        path \\ ".",
        n_workers \\ 4,
        headers \\ []
      ) do
    {:ok, pid} = Downloadex.Scheduler.start_link({urls, path, n_workers, headers})

    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, _, _, _} ->
        :ok
    end
  end
end
