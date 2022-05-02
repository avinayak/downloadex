defmodule Downloadex.Utils do
 def get_url_filename(url) do
    url |> URI.parse() |> Map.fetch!(:path) |> Path.basename()
  end
end
