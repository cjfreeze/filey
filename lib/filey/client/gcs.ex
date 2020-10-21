defmodule Filey.Client.GCS do
  alias Filey.Client
  @behaviour Client

  def upload(bucket, file, file_path, opts) do
    upload_path = get_path(file, opts)

    with {:ok, _} <- GCS.upload_object(bucket, upload_path, file_path, file.content_type),
         {:ok, _} <- make_public(bucket, file, opts) do
      {:ok, upload_path}
    end
  end

  def download(bucket, file, _opts) do
    GCS.download_object(bucket, file.path)
  end

  def delete(bucket, file, _opts) do
    GCS.delete_object(bucket, file.path)
  end

  def get_path(%{id: id, filename: filename}, _opts) do
    "#{id}/#{filename}"
  end

  def get_url(bucket, file, _opts) do
    "https://storage.googleapis.com/#{bucket}/#{file.path}"
  end

  def make_public(bucket, file, opts) do
    upload_path = get_path(file, opts)
    GCS.make_public(bucket, upload_path)
  end
end
