defmodule App.Factory do
  alias App.Repo

  def build(:model) do
    %Similarity.Model{name: "tf_idf", state: :enabled}
  end
  # api
  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
