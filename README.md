# Google Docs Divider

Этот бот может разбивать документ Google Doc на части, окрашивать их и назначать для работы разным пользователям.

Возможные команды:

- `/start` - выводит эту инструкцию

- `/help` - рассказывает о нашем алгоритме работы с документами

- `/process URL` - стартует алгоритм обработки готового документа, находящегося по адресу _URL_

- `/restart URL` - удаляет все метки, очищает фон и перезапускает работу над документом, находящимся по адресу _URL_

- `/in` - первые 15 минут после старта работы над документом все желающие участвовать в переводе могут ответить этой командой, чтобы получить свой кусок документа

- `/in N` - то же, что и предыдущая команда, но выполнивший при разделении текста получит в N раз больше текста, чем тот, кто выполнил просто команду /in

- `/wait` - можно записаться на перевод следующего, еще не начатого, документа этой командой

- `/wait N` - то же, что и предыдущая команда, но когда документ появится, вам будет назначено N частей

- `/unwait` - отказаться от ожидания следующего, еще не начатого

- `/forceUnwait REFERENCE` - КОМАНДА ТОЛЬКО ДЛЯ АДМИНА!!! Принудительно отменяет заявку указанного человека на ожидание следующего, еще не начатого, документа. Человек указывается через референс (Введите @ и выберите из предложенных вариантов. Если выбранный человек не имеет логина, выберется его имя. Если людей с таким именем несколько, нужно ввести через пробел его фамилию)

- `/out` - если согласились участвовать в переводе, но по каким-то причинам не можете, эта команда позволит вам отказаться

- `/share` - если согласились участвовать в переводе, но по каким-то причинам не можете закончить, эта команда поможет попросить помощи. Если у вас несколько кусков, в таком формате вы передадите их все другому добровольцу

- `/share N` - в таком формате вы передадите только выбранный кусок по его порядковому номеру другому добровольцу

- `/take` - этой командой вы можете согласиться помочь и перевести часть текста, предложенную другим добровольцем. Метки в тексте по предложенным частям текста будут заменены на ваши

- `/finish` - говорит боту, что вы закончили работу над своими кусками текста. В том числе над теми, которыми вы пытались поделиться, если их никто не взял

- `/subscribe` - если написать боту В ЛИЧКУ эту команду, то вам будут приходить оповещения, когда документ появился в чате и когда он размечен и готов к переводу

- `/unsubscribe` - выполните эту команду, чтобы отказаться от личных оповещений от бота

- `/status` - выводит статус текущего документа

- `/forceShare REFERENCE` - КОМАНДА ТОЛЬКО ДЛЯ АДМИНА!!! Принудительно шарит все куски указанного человека. Человек указывается через референс (Введите @ и выберите из предложенных вариантов. Если выбранный человек не имеет логина, выберется его имя. Если людей с таким именем несколько, нужно ввести через пробел его фамилию)

- `/forceFinish` - КОМАНДА ТОЛЬКО ДЛЯ АДМИНА!!! Принудительно завершает работу над документом и очищает его от меток

- `/forceStart` - КОМАНДА ТОЛЬКО ДЛЯ АДМИНА!!! Принудительно разделить документ и начать работу, не дожидаясь остальных желающих

- `/divide URL` - разделяет документ, находящийся по адресу _URL_, на несколько частей (около полстраницы каждая)

- `/divide URL N` - разделяет документ, находящийся по адресу _URL_, на _N_ частей

- `/clear URL` - очищает фон в документе по адресу _URL_
