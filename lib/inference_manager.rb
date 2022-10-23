# frozen_string_literal: true

class InferenceManager

  def initialize(post)
      @post = post
  end

  def classify_post
    response = Excon.post("#{SiteSettings.disorder_inference_service_api_endpoint}/api/v1/classify",
      {
        body: {
          model: SiteSettings.disorder_inference_service_api_model,
          content: @post.raw
        }
      })
    classification = JSON.parse(response)
    @post.custom_fields['disorder'] = classification


  end
end