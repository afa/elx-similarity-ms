class Similarity::Model < ApplicationRecord
  has_many :documents

  enum state: { enabled: 1, disabled: 0 }, _prefix: true
end
