class CreateSimilarityTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :similarity_tokens do |t|
      t.string :value, unique: true, index: true, null: false
    end
  end
end
