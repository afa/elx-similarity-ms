module Similarity
  module Strategies
    STRATEGIES = {
      none: Similarity::Strategies::None,
      tf_idf: Similarity::Strategies::TfIdf
    }.freeze

    def strategy(sym)
      STRATEGIES[sym.to_sym] || Similarity::Strategies::None
    end

    module_function :strategy
  end
end
