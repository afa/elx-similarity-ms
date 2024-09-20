class CreateSimilarityTokenCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :similarity_token_counts, id: false do |t|
      t.references :token, foreign_key: { to_table: :similarity_tokens }, index: true, null: false
      t.references :document, foreign_key: { to_table: :similarity_documents }, index: true, null: false
      t.integer :count, null: false
    end
  end
end
