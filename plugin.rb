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
  end


  
#   NewPostManager.add_handler do |manager|
#     #next if false





#     result = manager.perform_create_post
#     if result.success?
#       #do stuff
#     end

#     result
#   end
end