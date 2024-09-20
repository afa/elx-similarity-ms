module Similarity
  class UpdateAvgDocLength < BaseInteractor
    param :model

    def call
      avg = calc_average
      model.update(avg_doc_length: avg)
    end

    def calc_average
      tokens = Similarity::Token.connection.select_all(tokens_sql)
        .to_a
        .map { |h| h['sum'].to_f }
        .first
      tokens / model.documents.count.to_f
    end

    def tokens_sql
      <<-SQL.squish
        select sum(count) sum
          from similarity_token_counts
          inner join similarity_documents
            on document_id = similarity_documents.id
          where model_id = #{model.id}
      SQL
    end
  end
end
