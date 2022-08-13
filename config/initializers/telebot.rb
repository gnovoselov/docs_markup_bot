TELEBOT_CONFIG = YAML::load_file(Rails.root.join('config', 'telebot.yml'))
TELEBOT_HELP_MESSAGE = File.read(Rails.root.join('README.md'))
TELEGRAM_ADMIN = 'ReggaeMortis1'
