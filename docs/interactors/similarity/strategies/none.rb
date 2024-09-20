module Similarity
  module Strategies
    class None < BaseStrategy
      param :which

      def call
        []
      end
    end
  end
end
