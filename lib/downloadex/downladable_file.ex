defmodule Downloadex.DownloadableFile do
  @moduledoc false
  defstruct [
    :url,
    :path,
    size: 0,
    downloaded: 0,
    status: false,
    error: nil,
    retry_count: 0,
    headers: []
  ]
end
