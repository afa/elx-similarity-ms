module Similarity
  module Strategies
    class BaseStrategy < BaseInteractor

      private

      def select_similar(doc)
        Similarity::DocumentRank
          .connection
          .select_all(similar_sql(doc))
          .to_a
          .map { |h| h['left_id'] == doc.id ? h['right_id'] : h['left_id'] }
          .map { |i| Similarity::Document.find_by(id: i)&.main_object }
          .compact
      end

      def similar_sql(doc)
        <<-SQL
          select rank, id, main_object_type, main_object_id, left_id, right_id from
          (
            select rank, similarity_documents.id id, main_object_type, main_object_id, left_id, right_id
              from similarity_document_ranks
              inner join similarity_documents
                on (similarity_documents.id = similarity_document_ranks.left_id
                  or similarity_documents.id = similarity_document_ranks.right_id)
              inner join units on units.product_id = main_object_id
              inner join items on items.unit_id = units.id
              where main_object_type = 'Product' and items.price > 0
                and similarity_documents.id = #{doc.id}
            union
            select rank, similarity_documents.id id, main_object_type, main_object_id, left_id, right_id
              from similarity_document_ranks
              inner join similarity_documents
                on (similarity_documents.id = similarity_document_ranks.left_id
                  or similarity_documents.id = similarity_document_ranks.right_id)
              inner join units on units.id = main_object_id
              inner join items on items.unit_id = units.id
              where main_object_type = 'Unit' and items.price > 0
                and similarity_documents.id = #{doc.id} and units.product_id is null
            ) sub
            order by sub.rank desc limit 100
        SQL
      end
    end
  end
end
