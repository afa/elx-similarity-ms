module Similarity
  class ScoreBm25 < BaseInteractor
    param :keys
    param :tokens
    option :main_model
    option :key_count_hash, default: -> {}

    K1 = 2.0
    B = 0.75

    def call
      total = tokens.values.sum.to_f
      av_coef = total / main_model.avg_doc_length.to_f
      tf = keys.map { |t| tokens.fetch(t, 0).to_f / total }
      docs_count = main_model.documents.count.to_f
      key_count = key_count_hash || Similarity::TokenCount
        .connection
        .select_all(count_sql)
        .to_a
        .to_h { |a| [a['value'], a['count']] }
      idf = keys.map { |t| 1 + Math.log(docs_count / (1 + key_count.fetch(t, 0))) }
      tf.zip(idf).map { |t, i| i * (t * (K1 + 1) / (t + (K1 * (1 - B + (B * av_coef))))) }
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
