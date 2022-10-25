# frozen_string_literal: true

module ::Disorder
  class InferenceManager
    CLASSIFICATION_LABELS = %w(toxicity severe_toxicity obscene identity_attack insult threat sexual_explicit)

    def initialize(post)
        @post = post
    end

    def classify_post
      response = Faraday.post("#{SiteSetting.disorder_inference_service_api_endpoint}/api/v1/classify",
        {
          model: SiteSetting.disorder_inference_service_api_model,
          content: @post.raw
        }.to_json
      )
      @classification = JSON.parse(response.body)
      stored_classification = {
        classification: @classification,
        model: SiteSetting.disorder_inference_service_api_model
      }
      PostCustomField.create!(post_id: @post.id, name: "disorder", value: stored_classification.to_json)
      consider_flagging
    end

    def consider_flagging
      return unless SiteSetting.disorder_flag_automatically
      @reasons = CLASSIFICATION_LABELS.filter do |label|
        @classification[label] >= SiteSetting.send("disorder_flag_threshold_#{label}")
      end

      flag_post! unless @reasons.empty?
    end

    def flag_post!
      PostActionCreator.create(
        User.find_by(id: Disorder::BOT_USER_ID),
        @post,
        :inappropriate,
        reason: @reasons.join('/')
      )
      @post.publish_change_to_clients! :acted
    end
  end
end