class ApplicationController < ActionController::API
  include RackSessionFix
  include AuthHelpers

  check_authorization if: :require_authorization?
  before_action :configure_permitted_parameters, if: :devise_controller?

  def index
    render json: 'Server is running'
  end

  private

  def require_authorization?
    !devise_controller? && current_user.present?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :username, :password ])
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :email, :password ])
  end
end
