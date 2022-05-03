defmodule Downloadex.Scheduler do
  @moduledoc false

  use GenServer
  alias Downloadex.{DownloadQueue, Monitor}

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
  def init({urls, path, n_workers, headers}) do
    DownloadQueue.initialzie(urls, path, headers)
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
  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end


  @impl true
  def terminate(_reason, _state) do
    :normal
  end

  @impl true
  def handle_cast(:done, 1) do
    Monitor.done(0)
    send(self(), :kill)
    {:noreply, 0}
  end


  @impl true
  def handle_cast(:done, worker_count) do
    Monitor.done(worker_count)
    {:noreply, worker_count - 1}
  end
end
