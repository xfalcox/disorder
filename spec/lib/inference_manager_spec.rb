# frozen_string_literal: true

require "rails_helper"

RSpec.describe Disorder::InferenceManager do
  before do
    SiteSetting.disorder_enabled = true
    stub_request(
      :post,
      "#{SiteSetting.disorder_inference_service_api_endpoint}/api/v1/classify",
    ).to_return(
      status: 200,
      body:
        '{"toxicity":78,"severe_toxicity":1,"obscene":6,"identity_attack":3,"insult":4,"threat":8,"sexual_explicit":5}',
    )
  end

  describe "perform!" do
    it "returns a classification" do
      response = Disorder::InferenceManager.perform!("test content")
      expect(response).to be_a(Hash)
      expect(response["toxicity"]).to eq(78)
      expect(response["severe_toxicity"]).to eq(1)
      expect(response["obscene"]).to eq(6)
      expect(response["identity_attack"]).to eq(3)
      expect(response["insult"]).to eq(4)
      expect(response["threat"]).to eq(8)
      expect(response["sexual_explicit"]).to eq(5)
    end
  end
end
