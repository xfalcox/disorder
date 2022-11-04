# frozen_string_literal: true

# name: disorder
# about: Automates toxicity detection is user posts using AI
# version: 7.0
# authors: xfalcox
# url: https://github.com/xfalcox/disorder
# required_version: 2.8.0
# transpile_js: true

enabled_site_setting :disorder_enabled

after_initialize do
  module ::Disorder
    PLUGIN_NAME = "disorder"
    BOT_USER_ID = -3
  end

  SeedFu.fixture_paths << Rails.root.join("plugins", "disorder", "db", "fixtures").to_s
  require_relative "lib/inference_manager.rb"
  require_relative "app/jobs/regular/classify_post.rb"

  on(:post_created) { |post| Jobs.enqueue(:classify_post, post_id: post.id) }
  on(:post_edited) { |post| Jobs.enqueue(:classify_post, post_id: post.id) }
end
