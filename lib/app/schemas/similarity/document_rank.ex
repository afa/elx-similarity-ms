defmodule Similarity.DocumentRank do
  use Ecto.Schema

  schema "similarity_document_rank" do
    field :rank, :float
    belongs_to :left, Similarity.Document
    belongs_to :right, Similarity.Document
  end
end
