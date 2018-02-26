module Api
  module V1
    class GithubWebhookController < Api::V1::ApiController
      protect_from_forgery with: :null_session
      include Concerns::ActAsApiRequest
      skip_before_action :authenticate_user!

      def filter
        slack_notification_service = SlackNotificationService.new(params)
        slack_notification_service.send_notification
      end
    end
  end
end
