require 'unicode_utils'
module Similarity
  class AddItemToCorpus < BaseInteractor
    param :object
    option :use_bigram, default: -> { false }
    option :score_model, default: -> { 'tf_idf' }
    option :average_document_length, default: -> {}

    SCORE_MODELS = {
      'tf_idf' => Similarity::ScoreTfIdf,
      'bm25' => Similarity::ScoreBm25
    }.freeze

    def call
      tokens = extract_tokens(decorated.description, decorated.name)
      tokens_counts = count(tokens)
      tokens_counts[''] = tokens_counts.values.sum
      model.tokens = tokens_counts
      update_main_model(tokens_counts)
      SimilarityDatum.transaction do
        main_model.save!
        update_ranks
      end
    end

    private

    def extract_tokens(text, name)
      stop_words = [' ', ',', '.', "\n", ';', ':', '!', '?', '-']
      UnicodeUtils.each_word(text).to_a +
        UnicodeUtils.each_word(name).to_a -
        stop_words +
        [format('manufacter:%s', decorated.manufacter&.name || '')] +
        decorated.colors.map { |c| format('color:%s', c.name) if c.name.present? }.compact +
        bigram(text, stop_words) +
        bigram(name, stop_words)
    end

    def bigram(text, stop_words)
      return [] unless use_bigram

      (UnicodeUtils.each_word(text).to_a - stop_words).each_cons(2) { |a| a.join(' ') }
    end

    def decorated
      @decorated ||= object.decorate
    end

    def count(tokens)
      tokens.group_by { |w| w }.transform_values(&:size)
    end

    def model
      @model ||= SimilarityDatum
                 .where(kind: score_model)
                 .where(identifier: format('%<cls>s:%<id>i', cls: object.class.name, id: object.id))
                 .first_or_initialize
    end

    def main_model
      @main_model ||= SimilarityDatum.where(kind: score_model).where(identifier: '').first_or_initialize
    end

    def update_main_model(tokens_count)
      model.tokens.each_key { |key| main_model.tokens[key] -= 1 if main_model.tokens.key?(key) }
      tokens_count.each_key do |key|
        main_model.tokens[key] ||= 0
        main_model.tokens[key] += 1
      end
    end

    def score_rank(keys, tokens)
      SCORE_MODELS[score_model].call(keys, tokens, main_model:, docs_count:, avrg_doc_length: avg_doc_len)
    end

    def docs_count
      @docs_count ||= SimilarityDatum.where(kind: score_model).where.not(identifier: '').count
    end

    def update_ranks
      SimilarityDatum.where(kind: score_model).find_each do |sim|
        next if sim.id == model.id.to_i

        next if sim.identifier == ''

        keys = (sim.tokens.keys + model.tokens.keys).uniq
        sim_rank = score_rank(keys, sim.tokens)
        rank = score_rank(keys, model.tokens)
        cos_rank = cos(rank, sim_rank)
        model.ranks[sim.identifier] = cos_rank
        sim.ranks[model.identifier] = cos_rank
        sim.save
      end
      model.renewed_at = Time.zone.now
      model.save
    end

    def cos(vec1, vec2)
      vec1.map.with_index { |v, i| v * vec2[i] }.sum /
        Math.sqrt(vec1.map { |v| v * v }.sum * vec2.map { |v| v * v }.sum)
    end

    def avg_doc_len
      @avg_doc_len ||= average_document_length || (
                       SimilarityDatum
                       .where(kind: score_model.to_sym)
                       .where.not(identifier: '')
                       .pluck(:tokens)
                       .map { |c| c[''].to_f }
                       .sum /
                       (SimilarityDatum.where(kind: score_model.to_sym).where.not(identifier: '').count || 1)
                     )
    end
  end
end
