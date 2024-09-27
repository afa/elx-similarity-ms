defmodule Similarity.Token do
  use Ecto.Schema

  schema "similarity_token" do
    field :value, :string
    has_many :counts, Similarity.TokenCount
  end
end
