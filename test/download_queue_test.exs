defmodule Downloadex.DownloadQueueTest do
  use ExUnit.Case

  alias Downloadex.{DownloadQueue, DownloadableFile}

  # setup do
  #   queue = start_supervised!(Downloadex.DownloadQueue)
  #   %{queue: queue}
  # end

  test "Queue" do
    DownloadQueue.initialzie(
      ["http://example.com/file1.txt", "http://example.com/file2.txt"],
      ".",
      []
    )

    assert DownloadQueue.dequeue() == %DownloadableFile{
             downloaded: 0,
             error: nil,
             path: ".",
             retry_count: 0,
             size: 0,
             status: false,
             url: "http://example.com/file2.txt"
           }

    DownloadQueue.enque(%DownloadableFile{
      url: "http://example.com/file3.txt",
      path: "./downloads"
    })

    assert DownloadQueue.dequeue() == %DownloadableFile{
             downloaded: 0,
             error: nil,
             path: ".",
             retry_count: 0,
             size: 0,
             status: false,
             url: "http://example.com/file1.txt"
           }

    assert DownloadQueue.dequeue() == %DownloadableFile{
             downloaded: 0,
             error: nil,
             path: "./downloads",
             retry_count: 0,
             size: 0,
             status: false,
             url: "http://example.com/file3.txt"
           }

    assert DownloadQueue.dequeue() == nil
  end
end
