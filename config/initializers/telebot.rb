TELEBOT_CONFIG = YAML::load_file(Rails.root.join('config', 'telebot.yml'))
TELEBOT_HELP_MESSAGE = File.read(Rails.root.join('README.md'))
TELEGRAM_ADMINS = %w[ReggaeMortis1 asternaks gnovoselov]
TELEGRAM_ADMIN_CHATS = [36599423, 149074096, 153039812]
TELEGRAM_CHAT_URL = 'https://t.me/+_wpahFTDavE2ODUy'
TELEGRAM_SUPPORT_CHAT = 153039812
