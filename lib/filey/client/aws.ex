defmodule Filey.Client.AWS do
  import SweetXml
  alias Filey.Client
  alias ExAws.S3
  @behaviour Client

  def upload(bucket, file, file_path, opts) do
    upload_path = get_path(file, opts)

    operation =
      file_path
      |> S3.Upload.stream_file()
      |> S3.upload(bucket, upload_path, content_type: file.content_type)

    with {:ok, _result} <- ExAws.request(operation) do
      {:ok, upload_path}
    end
  end

  def download(bucket, file, _opts) do
    operation = S3.get_object(bucket, file.path)

    with {:ok, %{body: body}} <- ExAws.request(operation) do
      {:ok, body}
    end
  end

  def delete(bucket, file, _opts) do
    operation = S3.delete_object(bucket, file.path)

    with {:ok, _} <- ExAws.request(operation) do
      {:ok, :deleted}
    end
  end

  def get_path(%{id: id, filename: filename}, _opts) do
    "#{id}/#{filename}"
  end

  def get_url(bucket, file, _opts) do
    region = get_region(bucket)
    "https://#{bucket}.s3.#{region}.amazonaws.com/#{file.path}"
  end

  def make_public(bucket, file, opts) do
    upload_path = get_path(file, opts)
    GCS.make_public(bucket, upload_path)
  end

  defp get_region(bucket) do
    :persistent_term.get("filey_aws_#{bucket}_region")
  rescue
    ArgumentError ->
      region = do_request_region(bucket)
      :ok = :persistent_term.put("filey_aws_#{bucket}_region", region)
      region
  end

  defp do_request_region(bucket) do
    operation = ExAws.S3.get_bucket_location(bucket)

    with {:ok, %{body: xml}} <- ExAws.request(operation) do
      xpath(xml, ~x"//LocationConstraint/text()")
    end
  end
end
