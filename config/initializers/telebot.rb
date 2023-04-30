TELEBOT_CONFIG = YAML::load_file(Rails.root.join('config', 'telebot.yml'))
TELEBOT_HELP_MESSAGE = File.read(Rails.root.join('README.md'))
TELEGRAM_ADMINS = %w[gnovoselov anna_olga]
TELEGRAM_ADMIN_CHATS = [153039812, 5589849475]
TELEGRAM_CHAT_URL = 'https://t.me/+_wpahFTDavE2ODUy'
TELEGRAM_SUPPORT_CHAT = 153039812
