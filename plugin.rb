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
  require_relative "lib/event_handler.rb"
  require_relative "lib/inference_manager.rb"
  require_relative "lib/classifier.rb"
  require_relative "lib/post_classifier.rb"
  require_relative "lib/post_validator.rb"
  require_relative "lib/chat_message_classifier.rb"
  require_relative "app/jobs/regular/classify_post.rb"
  require_relative "app/jobs/regular/classify_chat_message.rb"

  add_permitted_post_create_param(:disorder_warned)
  add_permitted_post_update_param(:disorder_warned)

  on(:post_created) { |post| EventHandler.handle_post_async(post) }
  on(:post_edited) { |post| EventHandler.handle_post_async(post) }
  on(:chat_message_created) { |chat_message| EventHandler.handle_chat_async(chat_message) }
  on(:chat_message_edited) { |chat_message| EventHandler.handle_chat_async(chat_message) }
  on(:before_create_post) { |post, opts| EventHandler.handle_post_sync(post, opts) }
end
