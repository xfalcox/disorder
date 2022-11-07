# frozen_string_literal: true

module ::Disorder
  class PostClassifier < Classifier
    def content
      @object.raw
    end
    
    def store_classification
      PostCustomField.create!(
        post_id: @object.id,
        name: "disorder",
        value: {
          classification: @classification,
          model: SiteSetting.disorder_inference_service_api_model,
        }.to_json,
      )
    end

    def flag!
      PostActionCreator.create(
        flagger,
        @object,
        :inappropriate,
        reason: @reasons.join("/"),
      )
      @object.publish_change_to_clients! :acted
    end
  end
end
