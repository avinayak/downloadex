defmodule Downloadex.DownloadQueue do
  @moduledoc false

  use GenServer

  alias Downloadex.DownloadableFile

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def initialzie(urls, path) do
    GenServer.cast(__MODULE__, {:initialzie, urls, path})
  end

  def dequeue() do
    GenServer.call(__MODULE__, :dequeue)
  end

  def enque(%DownloadableFile{} = url) do
    GenServer.cast(__MODULE__, {:enque, url})
  end

  # Server
  @impl true
  def init(:no_args) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:initialzie, urls, path}, _queue) do
    downloads = Enum.map(urls, &%DownloadableFile{url: &1, path: path})
    {:noreply, downloads}
  end

  @impl true
  def handle_cast({:enque, url}, queue) do
    {:noreply, [url | queue]}
  end

  @impl true
  def handle_call(:dequeue, _from, queue) do
    {:reply, Enum.at(queue, -1), Enum.drop(queue, -1)}
  end
end
