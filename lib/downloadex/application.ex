defmodule Downloadex.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Downloadex.Reporter,
      Downloadex.DownloadQueue,
      Downloadex.DownloaderSupervisor,
      {Downloadex.Scheduler,
       {[
          "https://hirise-pds.lpl.arizona.edu/download/PDS/RDR/ESP/ORB_025800_025899/ESP_025874_1515/ESP_025874_1515_RED.JP2",
          "https://hirise-pds.lpl.arizona.edu/download/PDS/EXTRAS/RDR/ESP/ORB_025800_025899/ESP_025874_1515/ESP_025874_1515_MRGB.JP2"
        ], ".", 2}}
    ]

    opts = [strategy: :one_for_all, name: Downloadex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
