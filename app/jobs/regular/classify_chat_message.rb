# frozen_string_literal: true

module ::Jobs
  class ClassifyChatMessage < ::Jobs::Base
    def execute(args)
      return unless SiteSetting.disorder_enabled

      chat_message_id = args[:chat_message_id]
      return if chat_message_id.blank?

      chat_message = ChatMessage.find_by(id: chat_message_id)
      return if chat_message&.message.blank?

      ::Disorder::ChatMessageClassifier.new(chat_message).classify!
    end
  end
end
