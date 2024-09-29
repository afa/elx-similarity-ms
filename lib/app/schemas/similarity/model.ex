defmodule Similarity.Model do
  use Ecto.Schema
  import Ecto.Query

  @derive {Jason.Encoder, only: [:id, :name, :state]}

  schema "similarity_model" do
    field :name, :string
    field :state, Ecto.Enum, values: [disabled: 0, enabled: 1]
    field :avg_doc_length, :float
    has_many :documents, Similarity.Document
  end

  def active do
    q = from m in Similarity.Model,
      where: m.state == :enabled,
      select: m
    App.Repo.all(q)
  end
end
