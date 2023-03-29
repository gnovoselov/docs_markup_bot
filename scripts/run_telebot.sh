#!/bin/bash

cd /root/docs_markup_bot

/root/.rbenv/shims/bundle exec rake telebot:run RAILS_ENV=production
