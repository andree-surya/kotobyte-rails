
require 'googleauth'
require 'googleauth/token_store'
require 'google-id-token'

class GoogleAuthenticator

  def initialize(callback_url:)
    @authorizer = create_default_authorizer(callback_url)
  end

  def authorization_url
    uri = URI(@authorizer.get_authorization_url)

    params = Rack::Utils.parse_query(uri.query)
    params.except! 'access_type', 'approval_prompt'

    uri.query = Rack::Utils.build_query(params)
    uri.to_s
  end

  def get_email(code)
    credentials = @authorizer.get_credentials_from_code(user_id: 0, code: code)

    data = GoogleIDToken::Validator.new.check(
        credentials.id_token,
        credentials.client_id,
        credentials.client_id
    )

    data['email']
  end

  private

    def create_default_authorizer(callback_url)
      scopes = ['email']

      client_id = Google::Auth::ClientId.new(
          Rails.configuration.app[:google_client_id],
          Rails.configuration.app[:google_client_secret]
      )

      Google::Auth::UserAuthorizer.new(
          client_id, scopes, MemoryTokenStore.new, callback_url
      )
    end

    class MemoryTokenStore < Google::Auth::TokenStore
      def initialize
        @store = {}
      end

      def load(id)
        @store[id]
      end

      def store(id, token)
        @store[id] = token
      end

      def delete(id)
        @store.delete(id)
      end
    end
end
