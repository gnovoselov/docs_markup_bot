#!/bin/bash

cd /root/docs_markup_bot

bin/rake telebot:run RAILS_ENV=production
