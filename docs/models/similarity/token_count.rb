class Similarity::TokenCount < ApplicationRecord
  belongs_to :token
  belongs_to :document
end
