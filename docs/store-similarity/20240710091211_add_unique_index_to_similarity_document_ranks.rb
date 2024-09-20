class AddUniqueIndexToSimilarityDocumentRanks < ActiveRecord::Migration[6.1]
  def change
    add_index :similarity_document_ranks, [:left_id, :right_id], unique: true
  end
end
