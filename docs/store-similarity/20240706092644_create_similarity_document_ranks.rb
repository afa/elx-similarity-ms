class CreateSimilarityDocumentRanks < ActiveRecord::Migration[6.1]
  def change
    create_table :similarity_document_ranks, id: false do |t|
      t.references :left, foreign_key: { to_table: :similarity_documents }, index: true
      t.references :right, foreign_key: { to_table: :similarity_documents }, index: true
      t.decimal :rank, precision: 10, scale: 9, index: true
    end
  end
end
