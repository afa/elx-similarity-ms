defmodule App.Repo.Migrations.CreateSimilarityTables do
  use Ecto.Migration

  def change do
    create table(:similarity_model) do
      add :name, :string, null: false
      add :state, :integer, default: 0, null: false
      add :avg_doc_length, :float
    end

    create table(:similarity_document) do
      add :text, :text
      add :name, :text
      add :model_id, references("similarity_model", on_delete: :delete_all)
      add :state, :integer, default: 0, null: false
      add :main_object, :string, null: false, comment: "string with document identifier from request"
      add :tokenized_at, :bigint
      add :ranked_at, :bigint
    end

    create table("similarity_token") do
      add :value, :string
    end

    create table("similarity_token_count") do
      add :token_id, references("similarity_token", on_delete: :delete_all)
      add :document_id, references("similarity_document", on_delete: :delete_all)
      add :count, :bigint, null: false
    end

    create table("similarity_document_rank") do
      add :left_id, references("similarity_document", on_delete: :delete_all)
      add :right_id, references("similarity_document", on_delete: :delete_all)
      add :rank, :float, null: false
    end
    create index("similarity_model", [:name], unique: true)
    create index("similarity_model", [:state])

    create index("similarity_document", [:main_object, :model_id], unique: true)

    create index("similarity_token", [:value], unique: true)

    create index("similarity_document_rank", [:left_id, :right_id], unique: true)
    create index("similarity_document_rank", [:rank])
  end
end
