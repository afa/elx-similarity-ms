defmodule Similarity.TokenCount do
  use Ecto.Schema

  schema "similarity_token_count" do
    field :count, :integer
    belongs_to :token, Similarity.Token
    belongs_to :document, Similarity.Document
  end
end
