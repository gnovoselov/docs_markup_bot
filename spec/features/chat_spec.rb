require 'rails_helper'

RSpec.describe 'Document processing', type: :feature, vcr: true do # , vcr: { record: :new_episodes }
  let!(:chat) { create(:chat) }
  let(:service) { IncomingMessageService }
  let(:bot) { double(api: bot_api) }
  let(:bot_api) { double }
  let(:pending_document) { chat.reload.documents.pending.last }

  let(:document_url) { 'https://docs.google.com/document/d/1EmFypTi0XIX_lcDfT-FC072bxM6AP-b1yXqHW4WQoJ4/edit' }

  let(:message) do
    ->(text, participant) do
      double(
        text: text, 
        chat: double(id: chat.id),
        from: double(
          participant ? 
            participant.attributes.slice(*%w[first_name last_name username]) : 
            attributes_for(:participant)
        )
      )
    end
  end
  let(:send_message) do
    ->(text, participant = nil) do
      service.perform(bot: bot, message: message[text, participant])
    end
  end
  let(:expect_response) do
    ->(text) { expect(bot_api).to receive(:send_message).with(chat_id: chat.id, text: a_string_matching(text)) }
  end
  let(:expect_notification) do
    ->(text) { expect_any_instance_of(NotificationsService).to receive(:send_message).with(anything, chat_id: chat.id, text: a_string_matching(text)) }
  end
  let(:after_receiving) do
    ->(options) do
      if options[:expect_response].present?
        Array(options[:expect_response]).each do |response|
          expect_response[response]
        end
      end
      if options[:expect_notification].present?
        Array(options[:expect_notification]).each do |notification|
          expect_notification[notification]
        end
      end
      send_message[options[:message], options[:from]]
    end
  end
  let(:allow_replace_wip_labels) do
    ->(count) { allow_any_instance_of(WipReplaceService).to receive(:call).and_return(count) }
  end

  let(:waiter) { build(:participant, first_name: 'Tatyana', last_name: 'Schimmel') }
  let(:admin) { build(:participant, :admin) }
  let(:translator) { build(:participant, first_name: 'Cynthia', last_name: 'Runolfsson') }

  before do
    allow(bot_api).to receive(:send_message)
    allow_any_instance_of(NotificationsService).to receive(:send_message)
  end

  scenario 'basic flow' do
    after_receiving[{
      message: '/status',
      expect_response: "Сейчас никаких переводов не ведется.\nВы можете записаться на перевод следующего документа командой /wait"
    }]

    after_receiving[{
      message: '/wait',
      from: waiter,
      expect_response: "Спасибо за вашу заявку! Как только появится новый документ, у вас будет 1 часть. Вы можете отписаться командой /unwait"
    }]

    after_receiving[{
      message: '/unwait',
      from: waiter,
      expect_response: "Ничего! Все планы меняются. Не расстраивайтесь: вы сможете помочь с переводом в следующий раз!"
    }]

    after_receiving[{
      message: '/wait',
      from: waiter,
      expect_response: "Спасибо за вашу заявку! Как только появится новый документ, у вас будет 1 часть. Вы можете отписаться командой /unwait"
    }]

    after_receiving[{
      message: "/process #{document_url}",
      from: admin,
      expect_response: [
        "Друзья, у нас есть новый документ для перевода!\nСтраниц в нем примерно 12 с небольшим.\n\nКто участвует, нажмите, пожалуйста, /in",
        "@#{waiter.username} #{waiter.first_name} #{waiter.last_name}, у вас 1 часть"
      ]
    }]

    after_receiving[{
      message: '/in 2',
      from: translator,
      expect_response: [
        "По новым правилам мы больше не можем брать в работу несколько частей. Вам будет назначена одна часть.",
        "Делим на 2"
      ]
    }]

    after_receiving[{
      message: '/in',
      from: translator,
      expect_response: "Вы уже участвуете в переводе этого документа. Всего у вас 1 часть. Делим на 2"
    }]

    after_receiving[{
      message: '/out',
      from: translator,
      expect_response: "Вы больше не участвуете в переводе этого документа. Сейчас добровольцев: 1"
    }]

    after_receiving[{
      message: '/in',
      from: translator,
      expect_response: "Делим на 2"
    }]

    after_receiving[{
      message: "/forceOut @#{waiter.username}",
      from: translator,
      expect_response: "У вас нет прав на принудительное исключение переводчиков"
    }]

    after_receiving[{
      message: "/forceOut @#{admin.username}",
      from: admin,
      expect_response: "@#{admin.username} не участвует в переводе этого документа. Сейчас добровольцев: 2"
    }]

    after_receiving[{
      message: "/forceOut @#{translator.username}",
      from: admin,
      expect_response: "#{translator.first_name} #{translator.last_name} больше не участвует в переводе этого документа. Сейчас добровольцев: 1"
    }]

    after_receiving[{
      message: '/in',
      from: translator,
      expect_response: "Делим на 2"
    }]
    
    after_receiving[{
      message: '/status',
      expect_response: "Набираем волонтеров для перевода текущего документа.\nСтраниц в нем примерно 12 с небольшим.\nПока делим на 2 части.\n\nВы не участвуете в переводе этого документа.\nДля участия нажмите /in"
    }]

    # after_receiving[{
    #   message: "/forceStart",
    #   from: admin,
    #   expect_notification: "OK. Документ разделен на части! Можно приступать к переводу.\n\nВнимание! В документе найдены продублированные ссылки.\n\n#{document_url}\n\nПо окончании нажмите, пожалуйста, /finish"
    # }]
    DividerService.new.divide_document(pending_document)

    after_receiving[{
      message: '/status',
      from: translator,
      expect_response: "Перевод документа в процессе.\nОн разделен на 2 части.\nВ работе еще 2.\n\nВы участвуете в переводе.\nУ вас в работе 1 часть"
    }]

    after_receiving[{
      message: '/share',
      from: waiter,
      expect_response: "Друзья, нужна помощь! Кто может взять в работу дополнительный кусок, нажмите, пожалуйста, /take"
    }]

    after_receiving[{
      message: '/take',
      from: waiter,
      expect_response: "Спасибо за помощь! Вам назначена дополнительная работа. Теперь у вас 1 часть"
    }]

    after_receiving[{
      message: "/forceShare @#{waiter.username}",
      from: admin,
      expect_response: "Друзья, нужна помощь! Кто может взять в работу дополнительный кусок, нажмите, пожалуйста, /take"
    }]

    after_receiving[{
      message: '/take',
      from: translator,
      expect_response: "Спасибо за помощь! Вам назначена дополнительная работа. Теперь у вас 2 части"
    }]

    after_receiving[{
      message: '/share 2',
      from: translator,
      expect_response: "Друзья, нужна помощь! Кто может взять в работу дополнительный кусок, нажмите, пожалуйста, /take"
    }]

    allow_replace_wip_labels[1]

    after_receiving[{
      message: '/take',
      from: waiter,
      expect_response: "Спасибо за помощь! Вам назначена дополнительная работа. Теперь у вас 1 часть"
    }]

    after_receiving[{
      message: '/finish',
      from: waiter,
      expect_response: "В работе еще 1 часть"
    }]

    after_receiving[{
      message: '/status',
      from: waiter,
      expect_response: "Перевод документа в процессе.\nОн разделен на 2 части.\nВ работе еще 1.\n\nВы уже завершили перевод своих частей текста.\nИх было у вас в работе 1"
    }]

    after_receiving[{
      message: '/finish',
      from: translator,
      expect_response: [
        "@#{waiter.username} @#{translator.username} \nСпасибо всем за работу!",
        "#{TELEGRAM_ADMINS.map { |s| "@#{s}" }.join(' ')} Перевод готов #{document_url}"
      ]
    }]

    after_receiving[{
      message: '/status',
      expect_response: "Сейчас никаких переводов не ведется.\nВы можете записаться на перевод следующего документа командой /wait"
    }]
  end
end
