module Similarity
  class Cleanup < BaseInteractor
    CHUNK_SIZE = 1_000

    def call
      list = deleted_products
      list += deleted_units
      list += producted_units
      list.uniq!
      puts "Counted #{list.size} documents for deletion."
      drop_ranks(list)
      drop_token_counts(list)
      drop_documents(list)
      update_documents_size
    end

    private

    def deleted_products
      deleted(Product)
    end

    def deleted_units
      deleted(Unit)
    end

    def producted_units
      Similarity::Document
        .connection
        .select_all(producted_sql)
        .rows
        .flatten
    end

    def drop_ranks(list)
      list.each_slice(CHUNK_SIZE) { |l| Similarity::DocumentRank.where(left_id: l).order(false).delete_all }
      list.each_slice(CHUNK_SIZE) { |l| Similarity::DocumentRank.where(right_id: l).order(false).delete_all }
    end

    def drop_token_counts(list)
      list.each_slice(CHUNK_SIZE) { |l| Similarity::TokenCount.where(document_id: l).order(false).delete_all }
    end

    def drop_documents(list)
      list.each_slice(CHUNK_SIZE) { |l| Similarity::Document.where(id: l).order(false).delete_all }
    end

    def update_documents_size
      Similarity::Model.all.each { |m| Similarity::UpdateAvgDocLength.call(m) }
    end

    def deleted(klass)
      Similarity::Document
        .connection
        .select_all(deleted_sql(klass.name, klass.table_name))
        .rows
        .flatten
    end

    def deleted_sql(name, table_name)
      <<-SQL.squish
        select similarity_documents.id document
          from similarity_documents
          left outer join #{table_name}
            on #{table_name}.id = main_object_id
          where #{table_name}.id is null and main_object_type = '#{name}'
      SQL
    end

    def producted_sql
      <<-SQL.squish
        select similarity_documents.id document
          from similarity_documents
          inner join units
            on main_object_id = units.id
          where main_object_type = 'Unit' and units.product_id is not null 
      SQL
    end
  end
end
