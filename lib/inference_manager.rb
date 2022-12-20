# frozen_string_literal: true

module ::Disorder
  class InferenceManager
    def self.perform!(content)
      response =
        Faraday.post(
          "#{SiteSetting.disorder_inference_service_api_endpoint}/api/v1/classify",
          { model: SiteSetting.disorder_inference_service_api_model, content: content }.to_json,
          { "Referer" => Discourse.base_url, "Content-Type" => "application/json" },
        )

      raise Net::HTTPBadResponse unless response.status == 200

      JSON.parse(response.body)
    end
  end
end
