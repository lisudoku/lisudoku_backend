class Api::RegistrationsController < Devise::RegistrationsController
  include AuthHelpers
  before_action :configure_permitted_parameters
  respond_to :json

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ])
  end

  def respond_with(resource, _opts = {})
    resource.persisted? ? register_success(resource) : register_failed(resource)
  end

  def register_success(user)
    render_user(user)
  end

  def register_failed(user)
    render json: {
      errors: user.errors.full_messages,
    }, status: :bad_request
  end
end
