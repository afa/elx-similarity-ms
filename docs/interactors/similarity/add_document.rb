module Similarity
  class AddDocument < BaseInteractor
    param :object
    param :model

    def call
      document = Similarity::Document
        .where(main_object: object, model: Similarity::Model.find_by(name: model))
        .first_or_initialize
      document.text = object.decorate.description
      document.name = object.decorate.name
      document.state = :created
      document.save
    end
  end
end
