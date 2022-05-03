defmodule Downloadex.Utils do
  @moduledoc """
  Utilities for Downloadex.
  """

 def get_url_filename(url) do
    url |> URI.parse() |> Map.fetch!(:path) |> Path.basename()
  end
end
