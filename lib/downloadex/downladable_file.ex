defmodule Downloadex.DownloadableFile do
  @moduledoc """
  Structure for a downloadable file.
  """
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
