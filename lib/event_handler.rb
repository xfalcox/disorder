# frozen_string_literal: true

module ::Disorder
  class EventHandler
    class << self
      def handle_post_async(post)
        return if group_bypass?(post.user)
        Jobs.enqueue(:classify_post, post_id: post.id)
      end

      def handle_chat_async(chat_message)
        return if group_bypass?(chat_message.user)
        Jobs.enqueue(:classify_chat_message, chat_message_id: chat_message.id)
      end

      def handle_post_sync(post, opts)
        return if group_bypass?(post.user)

        if SiteSetting.disorder_block_posting_above_toxicity ||
             (SiteSetting.disorder_warn_posting_above_toxicity && !opts["disorder_warned"])
          ::Disorder::PostValidator.new(post).classify!
        end
      end

      def group_bypass?(user)
        user.groups.pluck(:id).intersection(SiteSetting.disorder_groups_bypass_map).present?
      end
    end
  end
end
