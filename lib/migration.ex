defmodule Filey.Migration do
  defmacro __using__(_opts \\ []) do
    quote do
      use Ecto.Migration

      def change do
        create table(:files, primary_key: false) do
          add(:id, :uuid, primary_key: true)
          add(:metadata, :map, default: nil)
          add(:bucket, :string, null: false)
          add(:filename, :string, null: false)
          add(:content_type, :string)
          add(:path, :string)

          timestamps(type: :utc_datetime_usec)
        end
      end
    end
  end
end
