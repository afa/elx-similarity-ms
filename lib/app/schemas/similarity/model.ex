defmodule Similarity.Model do
  use Ecto.Schema
  @derive {Jason.Encoder, only: [:id, :name, :state]}

  schema "similarity_model" do
    field :name, :string
    field :state, Ecto.Enum, values: [disabled: 0, enabled: 1]
    field :avg_doc_length, :float
    has_many :documents, Similarity.Document
  end
end
