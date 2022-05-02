defmodule Downloadex.Scheduler do
  @moduledoc false

  use GenServer
  alias Downloadex.{DownloadQueue, Reporter}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def next_url() do
    GenServer.cast(__MODULE__, {:next_url})
  end

  def done do
    GenServer.cast(__MODULE__, :done)
  end

  @impl true
  def init({urls, path, n_workers}) do
    DownloadQueue.initialzie(urls, path)
    Process.send_after(self(), :kickoff, 0)
    {:ok, n_workers}
  end

  @impl true
  def handle_info(:kickoff, worker_count) do
    1..worker_count
    |> Enum.each(fn id -> Downloadex.DownloaderSupervisor.add_worker(id) end)
    {:noreply, worker_count}
  end

  @impl true
  def handle_cast(:done, _worker_count = 1) do
    Reporter.done(0)
    System.halt(0)
  end

  @impl true
  def handle_cast(:done, worker_count) do
    {:noreply, worker_count - 1}
  end
end
