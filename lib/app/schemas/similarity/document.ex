defmodule Similarity.Document do
  use Ecto.Schema

  schema "similarity_document" do
    field :name, :string
    field :text, :string
    field :state, Ecto.Enum, values: [created: 0, tokenized: 1, ranked: 2]
    field :main_object, :string
    field :tokenized_at, :integer
    field :ranked_at, :integer
    belongs_to :model, Similarity.Model
  end
end
