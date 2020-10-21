defmodule Filey.Client do
  @type video_id :: String.t()
  @type bucket :: String.t()
  @callback upload(bucket, File.t(), binary, Keyword.t()) :: {:ok, any} | {:error, atom}
  @callback download(bucket, File.t(), Keyword.t()) :: {:ok, any} | {:error, atom}
  @callback delete(bucket, File.t(), Keyword.t()) :: {:ok, any} | {:error, atom}
  @callback get_path(File.t(), Keyword.t()) :: {:ok, binary} | {:error, atom}
  @callback get_url(bucket, File.t(), Keyword.t()) :: {:ok, binary} | {:error, atom}
end
