# frozen_string_literal: true

module ::Disorder
  class Classifier
    CLASSIFICATION_LABELS = %w[
      toxicity
      severe_toxicity
      obscene
      identity_attack
      insult
      threat
      sexual_explicit
    ]

    def initialize(object)
      @object = object
    end

    def content
    end

    def classify!
      @classification = InferenceManager.perform!(content)
      store_classification
      consider_flagging
    end

    def store_classification
    end

    def automatic_flag_enabled?
      SiteSetting.disorder_flag_automatically
    end

    def consider_flagging
      return unless automatic_flag_enabled?
      @reasons =
        CLASSIFICATION_LABELS.filter do |label|
          @classification[label] >= SiteSetting.send("disorder_flag_threshold_#{label}")
        end

      flag! unless @reasons.empty?
    end

    def flagger
      User.find_by(id: Disorder::BOT_USER_ID)
    end

    def flag!
    end
  end
end
