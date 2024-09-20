require 'unicode_utils'
module Similarity
  class TokenizeDocument < BaseInteractor
    param :document
    option :use_bigram, default: -> { false }

    def call
      return unless model

      tokens = extract_tokens(document.text, document.name)
      counts = count(tokens)
      existed = Similarity::Token.where(value: counts.keys).to_a.group_by(&:value)
      (counts.keys - existed.keys).each { |t| Similarity::Token.create(value: t) unless Similarity::Token.find_by(value: t) }
      Similarity::TokenCount.where(document:).delete_all
      counts.each do |name, cnt|
        Similarity::TokenCount.create(document:, token: Similarity::Token.find_by(value: name), count: cnt)
      end
      document.update(tokenized_at: Time.now.to_i, state: :tokenized)
    end

    def extract_tokens(text, name)
      split_text(text) +
        split_text(name) -
        stop_words +
        [format('manufacter:%s', decorated.manufacter&.name&.downcase || '')] +
        prepare_colors +
        bigram(text, stop_words) +
        bigram(name, stop_words)
    end

    def bigram(text, stop_words)
      return [] unless use_bigram

      (split_text(text) - stop_words).each_cons(2) { |a| a.join(' ') }
    end

    def split_text(text) = UnicodeUtils.each_word(text).to_a.map(&:downcase)

    def count(tokens) = tokens.group_by { |w| w }.transform_values(&:size)

    def stop_words = [' ', ',', '.', "\n", "\r", "\t", ';', ':', '!', '?', '-', '+', '*', '/']

    def prepare_colors
        decorated
          .colors
          .map { |c| (c.is_a?(Hash) ? c['localized_name'] : c.name.downcase).then { |clr| nil if clr.blank? } }
          .compact
          .map { |c| format('color:%s', c) }
    end

    def decorated
      @decorated ||= model.decorate
    end

    def model
      @model ||= document.main_object
    end
  end
end
