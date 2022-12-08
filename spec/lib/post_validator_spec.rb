# frozen_string_literal: true

require "rails_helper"

RSpec.describe Disorder::PostValidator do
  before do
    SiteSetting.disorder_enabled = true
    SiteSetting.disorder_flag_automatically = true

    stub_request(
      :post,
      "#{SiteSetting.disorder_inference_service_api_endpoint}/api/v1/classify",
    ).to_return(
      status: 200,
      body:
        '{"toxicity":78,"severe_toxicity":1,"obscene":6,"identity_attack":3,"insult":4,"threat":8,"sexual_explicit":5}',
    )
  end

  describe "classify!" do
    it "classifies a new post" do
      post = Fabricate(:post)
      classifier = Disorder::PostValidator.new(post)
      classifier.classify!
      expect(
        PluginStore.get("disorder", "post_revision_#{post.id}")[0]["classification"]["toxicity"],
      ).to eq(78)
      expect(post.errors[:raw].first).to include("Disorder")
    end
  end
end
