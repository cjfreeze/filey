defmodule Filey do
  defmacro __using__(opts \\ []) do
    quote do
      defmodule File do
        use Ecto.Schema
        import Ecto.Changeset

        @table unquote(Keyword.get(opts, :table, "files"))
        @bucket unquote(Keyword.fetch!(opts, :bucket))

        @primary_key {:id, :binary_id, autogenerate: true}
        schema @table do
          field(:metadata, :map)
          field(:filename, :string)
          field(:content_type, :string)
          field(:bucket, :string)
          field(:path, :string)

          timestamps(type: :utc_datetime_usec)
        end

        @doc false
        def changeset(file, attrs) do
          file
          |> cast(attrs, [
            :metadata,
            :filename,
            :content_type,
            :bucket,
            :path
          ])
          |> put_bucket()
          |> validate_required([:filename, :bucket])
        end

        def update_changeset(file, attrs) do
          file
          |> cast(attrs, [:metadata, :filename, :content_type, :path])
          |> validate_required([:filename, :bucket])
        end

        defp put_bucket(changeset) do
          put_change(changeset, :bucket, @bucket)
        end
      end

      alias __MODULE__.File
      @repo unquote(Keyword.fetch!(opts, :repo))

      def get_file(id), do: @repo.get(File, id)

      def fetch_file(id) do
        case get_file(id) do
          nil -> {:error, :not_found}
          %File{} = file -> {:ok, file}
        end
      end

      def create_file_from_upload(
            %{content_type: ct, path: path},
            filename,
            opts \\ []
          ) do
        create_file(path, filename, ct, opts)
      end

      def create_file(path, filename, ct, opts \\ []) do
        path
        |> create_file_multi(filename, ct, opts)
        |> @repo.transaction()
        |> case do
          {:ok, %{add_path: file}} -> {:ok, file}
          {:error, :create_file, _, _} -> {:error, :gcs_error}
          {:error, _, changeset, _} -> {:error, changeset}
        end
      end

      def create_file_multi_from_upload(
            %{content_type: ct, path: path},
            filename,
            opts \\ []
          ) do
        create_file_multi(path, filename, ct, opts)
      end

      def create_file_multi(path, filename, ct, opts \\ []) do
        meta = Keyword.get_lazy(opts, :metadata, fn -> %{} end)

        file_changeset =
          File.changeset(%File{}, %{
            filename: filename,
            content_type: ct,
            metadata: meta
          })

        Ecto.Multi.new()
        |> Ecto.Multi.insert(:create_file, file_changeset)
        |> Ecto.Multi.run(:upload_file, fn _, %{create_file: file} ->
          do_upload_file(file, path, opts)
        end)
        |> Ecto.Multi.update(:finalize_file, fn %{create_file: file, upload_file: path} ->
          File.update_changeset(file, %{path: path})
        end)
      end

      defp do_upload_file(%File{} = file, path, opts) do
        Filey.upload(file, path, opts)
      end

      def update_file(%File{} = file, attrs) do
        file
        |> File.update_changeset(attrs)
        |> @repo.update()
      end

      def delete_file(%File{} = file) do
        with {:ok, _} <- Filey.delete(file) do
          @repo.delete(file)
        end
      end

      def change_file(%File{} = file) do
        File.changeset(file, %{})
      end
    end
  end

  @client Application.get_env(:filey, :client, Filey.Client.Memory)
  alias File

  def upload(%{bucket: bucket} = file, path, opts \\ []) do
    @client.upload(bucket, file, path, opts)
  end

  def download(%{bucket: bucket} = file, opts \\ []) do
    @client.download(bucket, file, opts)
  end

  def delete(%{bucket: bucket} = file, opts \\ []) do
    @client.download(bucket, file, opts)
  end

  def get_path(file, opts \\ []) do
    @client.get_path(file, opts)
  end

  def get_url(%{bucket: bucket} = file, opts \\ []) do
    @client.get_url(bucket, file, opts)
  end
end
