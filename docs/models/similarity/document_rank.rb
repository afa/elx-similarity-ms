class Similarity::DocumentRank < ApplicationRecord
  belongs_to :left, class_name: 'Similarity::Document'
  belongs_to :right, class_name: 'Similarity::Document'
end
