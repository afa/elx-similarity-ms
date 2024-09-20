class Similarity::Document < ApplicationRecord
  belongs_to :model
  belongs_to :main_object, polymorphic: true

  has_many :left_document_ranks, class_name: 'Similarity::DocumentRank', foreign_key: :right_id
  has_many :right_document_ranks, class_name: 'Similarity::DocumentRank', foreign_key: :left_id

  has_many :token_counts
  has_many :tokens, through: :token_counts

  enum state: { created: 0, tokenized: 1, ranked: 2 }, _prefix: true
end
