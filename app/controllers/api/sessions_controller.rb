class Api::SessionsController < Devise::SessionsController
  include AuthHelpers
  respond_to :json

  # POST /login
  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource.present?
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      if !session[:return_to].blank?
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        login_success(resource)
      end
    else
      login_failure
    end
  end

  private

  def login_success(user)
    render_user(user)
  end
  
  def login_failure
    render json: {
      error: 'Invalid username / password combination',
    }, status: :unauthorized
  end
end
