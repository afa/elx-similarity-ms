module Similarity
  module Strategies
    class TfIdf < BaseStrategy
      param :which

      def call
        model = Similarity::Model.find_by(name: 'tf_idf')
        return [] unless model

        doc = model.documents.where(main_object: which).first
        return [] unless doc

        select_similar(doc).select { |p| p.decorate.in_stock? }.first(Similarity::MAX_COUNT)
      end
    end
  end
end
