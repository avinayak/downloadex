defmodule Downloadex.Downloader do
  use GenServer, restart: :transient

  alias Downloadex.{Scheduler, Reporter, DownloadQueue}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(id) do
    Process.send_after(self(), :do_one_url, 0)
    {:ok, id}
  end

  def handle_info(:do_one_url, id) do
    download(DownloadQueue.dequeue(), id)
  end

  defp download(nil, id) do
    Scheduler.done()
    Reporter.done(id)

    {:stop, :normal, id}
  end

  defp download(downloadable, id) do
    resp =
      HTTPoison.get!(downloadable.url, %{},
        stream_to: self(),
        async: :once
      )

    filename = downloadable.url |> URI.parse() |> Map.fetch!(:path) |> Path.basename()
    filepath = Path.join([downloadable.path, filename])
    file = File.open!(filepath, [:write])

    async_download = fn resp, fd, download_fn, total_size ->
      resp_id = resp.id

      receive do
        %HTTPoison.AsyncStatus{code: status_code, id: ^resp_id} ->
          # IO.inspect(status_code)
          HTTPoison.stream_next(resp)
          download_fn.(resp, fd, download_fn, 0)

        %HTTPoison.AsyncHeaders{headers: headers, id: ^resp_id} ->
          # IO.inspect(headers)
          total_size = Map.new(headers)["content-length"] |> String.to_integer()
          send_report(
            id,
            downloadable,
            total_size,
            0
          )

          HTTPoison.stream_next(resp)
          download_fn.(resp, fd, download_fn, total_size)

        %HTTPoison.AsyncChunk{chunk: chunk, id: ^resp_id} ->
          IO.binwrite(fd, chunk)
          # IO.inspect(fd)
          %File.Stat{size: size} = File.stat!(filepath)

          send_report(
            id,
            downloadable,
            total_size,
            size
          )

          HTTPoison.stream_next(resp)
          download_fn.(resp, fd, download_fn, total_size)

        %HTTPoison.AsyncEnd{id: ^resp_id} ->
          File.close(fd)
      end
    end

    async_download.(resp, file, async_download, 0)

    send(self(), :do_one_url)
    {:noreply, id}
  end

  defp send_report(id, downloadable, size, downloaded) do
    Reporter.update_progress(
      downloadable
      |> Map.put(:size, size)
      |> Map.put(:downloaded, downloaded),
      id
    )
  end

end
