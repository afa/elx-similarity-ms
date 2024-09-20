class CreateSimilarityModels < ActiveRecord::Migration[6.1]
  def change
    create_table :similarity_models do |t|
      t.string :name, unique: true
      t.integer :state, default: 0
    end
  end
end
