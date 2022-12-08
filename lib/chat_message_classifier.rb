# frozen_string_literal: true

module ::Disorder
  class ChatMessageClassifier < Classifier
    def content
      @object.message
    end

    def store_classification
      PluginStore.set(
        "disorder",
        "chat_message_#{@object.id}",
        {
          classification: @classification,
          model: SiteSetting.disorder_inference_service_api_model,
          date: Time.now.utc,
        },
      )
    end

    def flag!
      Chat::ChatReviewQueue.new.flag_message(
        @object,
        Guardian.new(flagger),
        ReviewableScore.types[:inappropriate],
      )
    end
  end
end
