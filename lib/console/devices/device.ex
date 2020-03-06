defmodule Console.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  alias Console.Organizations.Organization
  alias Console.Events.Event
  alias Console.Channels.Channel
  alias Console.Devices
  alias Console.Labels.DevicesLabels
  alias Console.Labels.Label
  alias Console.Helpers

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "devices" do
    field :name, :string
    field :dev_eui, :string
    field :app_key, :string
    field :app_eui, :string
    field :oui, :integer
    field :frame_up, :integer
    field :frame_down, :integer
    field :last_connected, :naive_datetime

    belongs_to :organization, Organization
    has_many :events, Event, on_delete: :delete_all
    many_to_many :labels, Label, join_through: DevicesLabels, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    attrs = Helpers.sanitize_attrs(attrs, ["name", "dev_eui", "app_eui", "app_key"])
    attrs = Helpers.upcase_attrs(attrs, ["dev_eui", "app_eui", "app_key"])

    changeset =
      device
      |> cast(attrs, [:name, :dev_eui, :app_eui, :app_key, :organization_id])
      |> put_change(:oui, Application.fetch_env!(:console, :oui))
      |> check_attrs_format()
      |> validate_required([:name, :dev_eui, :app_eui, :app_key, :oui, :organization_id])
  end

  defp check_attrs_format(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        dev_eui_valid = Map.get(changes, :dev_eui) == nil or String.match?(changes.dev_eui, ~r/[0-9a-fA-F]{16}/)
        app_eui_valid = Map.get(changes, :app_eui) == nil or String.match?(changes.app_eui, ~r/[0-9a-fA-F]{16}/)
        app_key_valid = Map.get(changes, :app_key) == nil or String.match?(changes.app_key, ~r/[0-9a-fA-F]{16}/)

        cond do
          !dev_eui_valid -> add_error(changeset, :message, "Dev EUI must be exactly 8 bytes long, and only contain characters 0-9 A-F")
          !app_eui_valid -> add_error(changeset, :message, "App EUI must be exactly 8 bytes long, and only contain characters 0-9 A-F")
          !app_key_valid -> add_error(changeset, :message, "App Key must be exactly 16 bytes long, and only contain characters 0-9 A-F")
          true -> changeset
        end
      _ ->
        changeset
    end
  end
end
