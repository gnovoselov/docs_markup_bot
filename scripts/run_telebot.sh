#!/bin/bash

cd /root/docs_markup_bot

/usr/local/rvm/rubies/ruby-3.1.2/bin/bundle exec rake telebot:run RAILS_ENV=production
