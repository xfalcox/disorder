# frozen_string_literal: true

module ::Jobs
  class ClassifyPost < ::Jobs::Base
    def execute(args)
      return unless SiteSetting.disorder_enabled

      post_id = args[:post_id]
      return if post_id.blank?

      post = Post.find_by(id: post_id, post_type: Post.types[:regular])
      return if post&.raw.blank?

      ::Disorder::PostClassifier.new(post).classify!
    end
  end
end
