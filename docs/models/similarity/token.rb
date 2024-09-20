class Similarity::Token < ApplicationRecord
  has_many :token_counts
  # has_many :documents, through: :token_counts
end
