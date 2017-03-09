
module Fastlane
  module Actions
    class TelegramAction < Action
      def self.run(params)
        uri = URI('https://api.telegram.org/bot153963542:AAGpG01sm2GmNG6WrfPzuNMhKDeTrdu328Y/sendMessage')
        params = { :text => "🍎 Controlio has been successfully deployed to the AppStore!", :chat_id => -1001107091033 }
        uri.query = URI.encode_www_form(params)
        Net::HTTP.get(uri)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Sends a message to Telegram chat'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :text,
                                       env_name: "FL_TELEGRAM_TEXT",
                                       description: "The message text",
                                       is_string: true,
                                       default_value: "")
        ]
      end

      def self.output
        [
          ['TELEGRAM_TEXT', 'The message text']
        ]
      end

      def self.authors
        ["etolstoy"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end