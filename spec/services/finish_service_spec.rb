require 'rails_helper'

RSpec.describe FinishService do
  subject(:call_service) { described_class.perform(params) }

  describe '.call' do
    let(:chat) { create(:chat) }
    let(:fuckuper) { create(:participant) }
    let(:inactive_user) { create(:participant) }
    let(:translator) { create(:participant) }
    let(:waiter) { create(:participant) }
    let(:admin) { create(:participant) }
    let(:document) { create(:document, chat: chat) }
    let(:old_document) { create(:document, :done, chat: chat, created_at: 30.days.ago) }
    let(:params) { { message: message} }

    before do
      allow(WipRemoveService).to receive(:perform)
      allow(ClearService).to receive(:perform)
      allow(NotificationsService).to receive(:perform)
    end

    context 'when finishing the document' do
      let!(:fuckuper_status) do
        create(:document_participant, :inactive, participant: fuckuper, document: document)
      end
      let!(:translator_status) do
        create(:document_participant, participant: translator, document: document)
      end
      let!(:waiter_status) do
        create(:document_participant, :inactive, participant: waiter, document: document)
      end
      let!(:admin_status) do
        create(:document_participant, :inactive, participant: admin, document: document)
      end
      let!(:inactive_user_status) do
        create(
          :document_participant, 
          :inactive, 
          participant: inactive_user, 
          document: old_document,
          created_at: 30.days.ago
        )
      end
      let!(:fuckup) { create(:fuckup, participant: fuckuper, document: document) }
      let(:telegram_statistics_chat) { 664432154 }
      let(:message) do
        double(
          text: Faker::Lorem.sentence, 
          chat: double(id: chat.id),
          from: double(
            translator.attributes.slice(*%w[first_name last_name username])
          )
        )
      end
      let(:current_participants) do
        "@#{fuckuper.username} #{fuckuper.first_name} #{fuckuper.last_name}\n" \
        "@#{translator.username} #{translator.first_name} #{translator.last_name}\n" \
        "@#{waiter.username} #{waiter.first_name} #{waiter.last_name}\n" \
        "@#{admin.username} #{admin.first_name} #{admin.last_name}"
      end
      let(:inactive_participants) do
        "@#{inactive_user.username} #{inactive_user.first_name} #{inactive_user.last_name}"
      end
      let(:fuckups) do
        "@#{fuckuper.username} #{fuckuper.first_name} #{fuckuper.last_name}"
      end
      let(:statistics_message) do
        "Статистика чата: Test chat\n\n" \
        "В переводе участвовали:\n#{current_participants}\n\n" \
        "Неактивные пользователи:\n#{inactive_participants}\n\n" \
        "Факапщики сегодня: #{fuckups}"
      end

      it 'sends statistics to admin' do
        expect(NotificationsService).to receive(:perform).with(
          notifications: [{
            chat_id: telegram_statistics_chat,
            text: statistics_message
          }]
        )
        call_service
      end
    end
  end
end
