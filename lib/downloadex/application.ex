defmodule Downloadex.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Downloadex.Monitor,
      Downloadex.DownloadQueue,
      Downloadex.DownloaderSupervisor
    ]

    opts = [strategy: :one_for_all, name: Downloadex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
