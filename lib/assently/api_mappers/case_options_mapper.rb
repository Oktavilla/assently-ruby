require "assently/api_mappers/case_event_subscription_mapper"

module Assently
  class InvalidCaseOptionError < ArgumentError; end

  module ApiMappers
    module CaseOptionsMapper
      def self.to_api options = {}, mappers = self.mappers
        options.reduce({}) do |api_hash, (client_key, value)|
          if mappers.key?(client_key)
            api_hash.merge(self.map(client_key, value, mappers))
          else
            api_hash
          end
        end || {}
      end

      private

      LOCALES = ->(locale) {
        {
          "sv" => "sv-SE",
          "fi" => "fi-FI",
          "en" => "en-US"
        }.fetch(locale) { raise Assently::InvalidCaseOptionError.new("Unknown locale: #{locale}") }
      }

      def self.map client_key, value, mappers = self.mappers
        mapper = mappers[client_key]

        if mapper.respond_to?(:call)
          mapper.call value
        else
          { mapper => value }
        end
      end

      def self.mappers
        {
          send_sign_request_email_to_parties: "SendSignRequestEmailToParties",
          send_finish_email_to_creator: "SendFinishEmailToCreator",
          send_finish_email_to_parties: "SendFinishEmailToParties",
          send_recall_email_to_parties: "SendRecallEmailToParties",
          cancel_url: "CancelUrl",
          procedure: "Procedure",
          locale: ->(value) {
            { "Culture" => LOCALES.call(value) }
          },
          continue: ->(options) {
            CaseOptionsMapper.to_api options, name: "ContinueName", url: "ContinueUrl", auto: "ContinueAuto"
          },
          event_callback: ->(value) {
            { "EventCallback" => CaseEventSubscriptionMapper.to_api(value) }
          }
        }
      end
    end
  end
end
