# README

This Telegram bot can accept a Google Doc link and divide the doc into several parts with different background.

Possible commands:

- `/start` - print this manual

- `/divide URL` - divide the Google Doc located at _URL_ into several parts (about half a page each)

- `/divide URL N` - divide the Google Doc located at _URL_ into _N_ parts

- `/wip URL N` - start woring on the _Nth_ part of the Google doc located at _URL_ (adds a `[WIP]` marker in the beginning of the part)

- `/finish URL N` - finish woring on the _Nth_ part of the Google doc located at _URL_ (removes all markers from the beginning of the part)

- `/clear URL` - clear text backgrounds in the Google Doc located at _URL_
