class AddAverageDocumentLengthToSimilarityModel < ActiveRecord::Migration[6.1]
  def change
    add_column :similarity_models, :avg_doc_length, :decimal, scale: 4, precision: 10
  end
end
