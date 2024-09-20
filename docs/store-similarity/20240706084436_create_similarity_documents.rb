class CreateSimilarityDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :similarity_documents do |t|
      t.mediumtext :text
      t.text :name
      t.references :model, foreign_key: { to_table: :similarity_models }, index: true
      t.integer :state, default: 0, index: true
      t.references :main_object, polymorphic: true, index: true
      t.integer :tokenized_at, limit: 8
      t.integer :ranked_at, limit: 8
    end
  end
end
