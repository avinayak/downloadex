defmodule Downloadex do
  @moduledoc """
  Documentation for `Downloadex`.
  """

  def download(urls, path, n_workers) do
    Downloadex.Scheduler.start_link({urls, path, n_workers})
  end
end

# Downloadex.download(["https://d214hhm15p4t1d.cloudfront.net/npr/223598b521fd02d762cf1416e074f1bf3ec7ef6b/img/city-guide-default.jpg"], ".", 3)
