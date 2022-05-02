defmodule Downloadex.Reporter do
  @moduledoc false

  alias Downloadex.Bars

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def update_progress(download, worker_id) do
    GenServer.cast(__MODULE__, {:update_progress, download, worker_id})
  end

  def done(worker_id) do
    GenServer.call(__MODULE__, {:done, worker_id})
  end

  @impl true
  def init(:no_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:update_progress, downloadable, worker_id}, current_downloads) do
    updated_state = Map.put(current_downloads, worker_id, downloadable)

    bars = Bars.render_bars(updated_state, "░", "█")

    for line <- bars do
      IO.puts(line)
    end

    IO.write(IO.ANSI.clear_line())
    IO.write(IO.ANSI.cursor_up(map_size(updated_state)))
    IO.write(IO.ANSI.blink_off())



    {:noreply, updated_state}
  end

  @impl true
  def handle_call({:done, worker_id}, _from, current_downloads) do
    updated_state = Map.delete(current_downloads, worker_id)

    if map_size(updated_state) == 0 do
      IO.write(IO.ANSI.clear_line())
    end

    {:reply, %{}, updated_state}
  end
end
