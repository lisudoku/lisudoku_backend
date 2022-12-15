class Api::SessionsController < Devise::SessionsController
  include AuthHelpers
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    current_user ? login_success(resource) : login_failure(resource)
  end

  def login_success(user)
    render_user(user)
  end
  
  def login_failure(user)
    render json: {
      error: 'Invalid username / password combination',
    }, status: :unauthorized
  end
end
