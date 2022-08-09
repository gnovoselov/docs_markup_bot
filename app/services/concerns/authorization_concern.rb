# frozen_string_literal: true

require "google/apis/docs_v1"
require "googleauth"
require "googleauth/stores/file_token_store"

module AuthorizationConcern
  extend ActiveSupport::Concern

  OOB_URI = "https://markupbot.novoselov.biz".freeze
  CREDENTIALS_PATH = Rails.root.join("config", "credentials.json").freeze
  # The file token.yml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = Rails.root.join("config", "token.yml").freeze
  SCOPE = Google::Apis::DocsV1::AUTH_DOCUMENTS
  USER_ID = "default".freeze

  private

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    credentials = authorizer.get_credentials USER_ID
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts "Open the following URL in the browser and enter the " \
          "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: USER_ID, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def authorizer
    @authorizer ||= Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  end

  def client_id
    Google::Auth::ClientId.from_file CREDENTIALS_PATH
  end

  def token_store
    Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  end
end
