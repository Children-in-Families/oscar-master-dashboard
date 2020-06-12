class ApplicationController < ActionController::Base
  private

  def create_instance_request
    # Update token every request
    current_admin_user.generate_token!

    HTTParty.post(
      "#{ENV["OSCAR_HOST"]}/api/v1/organizations",
      headers: { Authorization: "Token token=#{current_admin_user&.token}" },
      body: {
        full_name: params.dig(:organization, :full_name),
        short_name: params.dig(:organization, :short_name),
        logo: params.dig(:organization, :logo)
      }
    )
  end
end
