defmodule Downloadex.Downloader do
  @moduledoc """
  Genserver to download files from a queue of urls.
  This module is the core worker process that is spawned by the
  DownloaderSupervisor. It checks DownloadQueue for new urls to download.
  after init and also after each download till there are no more urls to download.
  Then, it calls done() on the Monitor.
  """

  use GenServer, restart: :transient

  alias Downloadex.{Scheduler, Monitor, DownloadQueue, Utils}

  require Logger

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @spec init(integer) :: {:ok, integer}
  def init(id) do
    Process.send_after(self(), :do_one_url, 0)
    {:ok, id}
  end

  def handle_info(:do_one_url, id) do
    download(DownloadQueue.dequeue(), id)
  end

  @spec get_file_length(any) :: nil | integer
  def get_file_length(headers) do
    case headers
         |> Enum.filter(fn {header, _value} -> String.downcase(header) == "content-length" end)
         |> Enum.at(0) do
      {_, value} -> String.to_integer(value)
      _ -> nil
    end
  end

  defp download(nil, id) do
    Scheduler.done()
    {:stop, :normal, id}
  end

  defp download(downloadable, id) do
    resp =
      HTTPoison.get!(downloadable.url, downloadable.headers,
        stream_to: self(),
        async: :once,
        hackney: [pool: false]
      )

    filename = Utils.get_url_filename(downloadable.url)
    filepath = Path.join([downloadable.path, filename])
    File.mkdir_p!(Path.dirname(filepath))
    file = File.open!(filepath, [:write])

    async_download = fn resp, fd, download_fn, total_size ->
      resp_id = resp.id

      receive do
        %HTTPoison.AsyncStatus{code: status_code, id: ^resp_id} ->
          case status_code do
            200 ->
              HTTPoison.stream_next(resp)
              download_fn.(resp, fd, download_fn, 0)

            code ->
              Logger.error("Unable to download: #{downloadable.url}: status code #{code}")
          end

        %HTTPoison.AsyncHeaders{headers: headers, id: ^resp_id} ->
          total_size = get_file_length(headers)

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

        %HTTPoison.Error{reason: _} ->
          if downloadable.retry_count < 5 do
            Logger.warn(
              "Re Queueing #{downloadable.url} for #{downloadable.retry_count(+1)} time"
            )

            retry(downloadable)
          end

        e ->
          Logger.error("Unable to download: #{downloadable.url}: #{e}")
      end
    end

    async_download.(resp, file, async_download, 0)

    send(self(), :do_one_url)
    {:noreply, id}
  end

  def retry(downloadable) do
    DownloadQueue.enque(Map.merge(downloadable, %{retry_count: downloadable.retry_count + 1}))
  end

  defp send_report(id, downloadable, size, downloaded) do
    Monitor.update_progress(
      downloadable
      |> Map.put(:size, size)
      |> Map.put(:downloaded, downloaded),
      id
    )
  end
end
