# frozen_string_literal: true

require "rails_helper"

RSpec.describe Disorder::EventHandler do
  fab!(:user) { Fabricate(:user) }
  let(:basic_topic_params) do
    { title: "hello world topic", raw: "my name is fred", archetype_id: 1, advance_draft: true }
  end
  fab!(:public_chat_channel) { Fabricate(:category_channel) }
  let(:creator) { PostCreator.new(user, basic_topic_params) }

  before { SiteSetting.disorder_enabled = true }

  context "posts async classification" do
    it "enqueues a classification job" do
      creator.create
      expect_job_enqueued(job: :classify_post, args: { post_id: creator.post.id })
    end
  end

  context "chat message async classification" do
    it "enqueues a classification job" do
      creator =
        Chat::ChatMessageCreator.create(
          chat_channel: public_chat_channel,
          user: user,
          content: "2 short",
        )
      expect_job_enqueued(job: :classify_chat_message, args: { chat_message_id: creator.chat_message.id })
    end
  end
end
