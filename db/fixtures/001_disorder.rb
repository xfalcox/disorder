# frozen_string_literal: true

disorder_username = "disorderbot"

def seed_primary_email
  UserEmail.seed do |ue|
    ue.id = Disorder::BOT_USER_ID
    ue.email = "disorder_email"
    ue.primary = true
    ue.user_id = Disorder::BOT_USER_ID
  end
end

unless user = User.find_by(id: Disorder::BOT_USER_ID)
  suggested_username = UserNameSuggester.suggest(disorder_username)

  seed_primary_email

  User.seed do |u|
    u.id = Disorder::BOT_USER_ID
    u.name = disorder_username
    u.username = suggested_username
    u.username_lower = suggested_username.downcase
    u.password = SecureRandom.hex
    u.active = true
    u.approved = true
    u.trust_level = TrustLevel[4]
  end
end

bot = User.find(Disorder::BOT_USER_ID)

# ensure disorder has a primary email
unless bot.primary_email
  seed_primary_email
  bot.reload
end

bot.update!(admin: true, moderator: false)

bot.create_user_option! if !bot.user_option

bot.user_option.update!(
  email_messages_level: UserOption.email_level_types[:never],
  email_level: UserOption.email_level_types[:never],
)

bot.create_user_profile! if !bot.user_profile

bot.user_profile.update!(bio_raw: I18n.t("disorder_bot.bio")) if !bot.user_profile.bio_raw

Group.user_trust_level_change!(Disorder::BOT_USER_ID, TrustLevel[4])

UserAvatar.register_custom_user_gravatar_email_hash(Disorder::BOT_USER_ID, "disorder@falco.dev")
