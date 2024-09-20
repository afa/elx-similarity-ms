class AddLangSimilarityModels < ActiveRecord::Migration[6.1]
  def up
    Similarity::Model.create name: 'tf_idf'
    Similarity::Model.create name: 'bm25'
  end

  def down
    Similarity::Model.find_by(name: 'tf_idf').destroy
    Similarity::Model.find_by(name: 'bm25').destroy
  end
end
