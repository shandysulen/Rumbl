defmodule Rumbl.User do
    use Rumbl.Web, :model

    schema "users" do
        field :name, :string
        field :username, :string
        field :password, :string, virtual: true # virtual fields are NOT persisted to the database
        field :password_hash, :string
        has_many :videos, Rumbl.Video

        timestamps()
    end

    def changeset(model, params \\ :invalid) do
        IO.puts("Here is the changeset:")
        model
        |> cast(params, ~w(name username), [])
        |> validate_length(:username, min: 1, max: 20)
        |> unique_constraint(:username)
    end

    def registration_changeset(model, params) do
        IO.puts("Now in the registration changeset")
        model
        |> changeset(params)
        |> cast(params, ~w(password), [])
        |> validate_length(:password, min: 6, max: 100)
        |> put_pass_hash()
        |> IO.inspect()
    end

    defp put_pass_hash(changeset) do
        case changeset do
            %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
                put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
            _ ->
                changeset
        end
    end
end