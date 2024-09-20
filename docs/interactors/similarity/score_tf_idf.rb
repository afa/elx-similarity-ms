module Similarity
  class ScoreTfIdf < BaseInteractor
    param :keys
    param :tokens
    option :main_model
    option :key_count_hash, default: -> {}
    # option :docs_count

    def call
      total = tokens.values.sum.to_f
      tf = keys.map { |t| tokens.fetch(t, 0).to_f / total }
      docs_count = main_model.documents.count.to_f
      key_count = key_count_hash || Similarity::TokenCount
        .connection
        .select_all(count_sql)
        .to_a
        .to_h { |a| [a['value'], a['count']] }
      idf = keys.map { |t| 1 + Math.log(docs_count / (1 + key_count.fetch(t, 0))) }
      # tf = (keys - ['']).map { |t| tokens.fetch(t, 0).to_f / total }
      # idf = (keys - ['']).map { |t| 1 + Math.log(main_model.tokens[''].to_f / (1 + main_model.tokens.fetch(t, 0))) }
      tf.zip(idf).map { |t, i| t * i }
    end

    def count_sql
      <<-SQL.squish
        select count(*) count, similarity_tokens.value value
          from similarity_token_counts
          inner join similarity_tokens on token_id = similarity_tokens.id
          inner join similarity_documents on document_id = similarity_documents.id
          where model_id = #{main_model.id}
          group by value
      SQL
    end
  end
end
