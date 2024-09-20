module Similarity
  class RankDocument < BaseInteractor
    SCORE_MODELS = {
      'tf_idf' => Similarity::ScoreTfIdf,
      'bm25' => Similarity::ScoreBm25
    }.freeze

    param :document
    option :skip_ranked, default: -> { false }

    def call
      my_token_list = Similarity::Token.joins(:token_counts).where(token_counts: { document: document }).pluck(:value)
      my_token_counts = Similarity::TokenCount
        .connection
        .select_all(count_sql(document))
        .to_a
        .to_h { |a| [a['value'], a['count']] }
      doc_key_count = Similarity::TokenCount
        .connection
        .select_all(doc_key_count_sql(document.model_id))
        .to_a
        .to_h { |a| [a['value'], a['count']] }
      Similarity::Document.where(model_id: document.model_id, state: %i[ranked tokenized]).where.not(id: document.id).find_in_batches(batch_size: 10_000) do |sims|
        print '|'
        sim_ids = sims.map(&:id)
        token_counters = Similarity::TokenCount
          .connection
          .select_all(counters_sql(sim_ids))
          .to_a
          .group_by { |a| a['document_id'] }
          .transform_values { |aa| aa.to_h { |a| [a['value'], a['count']] } }
        rank_list = sims.each_with_object([]) do |sim, arr|
          token_list = Similarity::Token.joins(:token_counts).where(token_counts: { document: sim }).pluck(:value)
          key_list = (my_token_list | token_list).sort
          token_counts = token_counters[sim.id]
          my_vector = SCORE_MODELS[model.name].call(key_list, my_token_counts, main_model: model, key_count_hash: doc_key_count)
          vector = SCORE_MODELS[model.name].call(key_list, token_counts, main_model: model, key_count_hash: doc_key_count)
          rnk = cos(my_vector, vector)
          arr << [sim.id, rnk] if rnk >= Similarity::MIN_RANK / 2.0
        end
        next if rank_list.empty?

        Similarity::DocumentRank.connection.execute(replace_sql(document.id, rank_list))
        Similarity::DocumentRank.where(right_id: document.id, left_id: rank_list.map(&:first)).order(false).delete_all
      end
      document.update(state: :ranked, ranked_at: Time.now.to_i)
    end

    def replace_sql(left, arr)
      <<-SQL.squish
        replace into similarity_document_ranks
          (left_id, right_id, rank)
          values
            #{arr.map { |a| format('(%i, %i, %10f)', left, a.first, a.last) }.join(', ')}
      SQL
    end

    def model
      @model ||= document.model
    end

    def counters_sql(ids)
      <<-SQL.squish
        select document_id, count, similarity_tokens.value value
          from similarity_token_counts
          inner join similarity_tokens on token_id = similarity_tokens.id
          where document_id in (#{ids.empty? ? '0' : ids.map(&:to_s).join(',')})
      SQL
    end

    def count_sql(document)
      <<-SQL.squish
        select count, similarity_tokens.value value
          from similarity_token_counts
          inner join similarity_tokens on token_id = similarity_tokens.id
          where document_id = #{document.id}
      SQL
    end

    def doc_key_count_sql(main_model_id)
      <<-SQL.squish
        select count(*) count, similarity_tokens.value value
          from similarity_token_counts
          inner join similarity_tokens on token_id = similarity_tokens.id
          inner join similarity_documents on document_id = similarity_documents.id
          where model_id = #{main_model_id}
          group by value
      SQL
    end

    def cos(vec1, vec2)
      vec1.map.with_index { |v, i| v * vec2[i] }.sum /
        Math.sqrt(vec1.map { |v| v * v }.sum * vec2.map { |v| v * v }.sum)
    end
  end
end
