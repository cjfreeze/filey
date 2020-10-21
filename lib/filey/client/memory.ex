defmodule Filey.Client.Memory do
  require Logger
  alias Filey.Client
  @behaviour Client

  def upload(bucket, %{} = file, path, _opts) do
    Logger.info("Uploading file: #{inspect(file)}")
    pid = get_pid(bucket)
    url = generate_path(file)

    with {:ok, body} <- File.read(path),
         :ok <- Agent.update(pid, fn f -> Map.put(f, url, body) end) do
      {:ok, url}
    end
  end

  def download(bucket, %{} = file, _opts) do
    Logger.info("Downloading file: #{inspect(file)}")
    pid = get_pid(bucket)
    {:ok, Agent.get(pid, fn f -> Map.get(f, file.path) end) || ""}
  end

  def get_by_url(bucket, url) do
    Logger.info("Downloading file at url #{url}")
    pid = get_pid(bucket)
    {:ok, Agent.get(pid, fn f -> Map.get(f, url) end)}
  end

  def delete(bucket, %{} = file, _opts) do
    Logger.info("Deleting file: #{inspect(file)}")
    pid = get_pid(bucket)
    url = generate_path(file)

    Agent.update(pid, fn f -> Map.delete(f, url) end)
  end

  def get_path(%{path: path}, _), do: path

  def get_url(_bucket, %{} = file, _),
    do: "#{host()}#{get_path(file, [])}"

  defp generate_path(%{id: id, filename: filename}) do
    "/files/#{id}/#{filename}"
  end

  defp get_pid(bucket) do
    name = agent_name(bucket)
    pid = Process.whereis(name)

    if is_pid(pid) and Process.alive?(pid) do
      pid
    else
      {:ok, pid} = Agent.start(fn -> %{} end, name: name)
      pid
    end
  end

  defp agent_name(bucket), do: :"#{__MODULE__}.#{bucket}"

  def dump(bucket) do
    Agent.get(get_pid(bucket), fn f -> f end)
  end

  defp host do
    Application.get_env(:filey, Filey.Client.Memory, [])
    |> Keyword.get(:host, "http://localhost:4000")
  end
end
