# frozen_string_literal: true

module ::Disorder
  class PostValidator < Classifier
    def content
      @object.raw
    end

    def classify!
      @classification = InferenceManager.perform!(content)
      store_classification
      consider_flagging
    end

    def store_classification
      revisions = PluginStore.get("disorder", "post_revision_#{@object.id}") || []
      revisions << {
        content: content,
        classification: @classification,
        model: SiteSetting.disorder_inference_service_api_model,
        date: Time.now.utc,
      }
      PluginStore.set("disorder", "post_revision_#{@object.id}", revisions)
    end

    def flag!
      @object.errors.add :raw,
                         :toxicity_above_threshold,
                         message: "#{@reasons.join("/")} is too high"
    end
  end
end
