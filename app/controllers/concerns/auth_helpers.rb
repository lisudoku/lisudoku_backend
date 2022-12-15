module AuthHelpers
  def current_token
    request.env['warden-jwt_auth.token']
  end

  def authorize_admin!
    authenticate_user!

    head :forbidden unless current_user.admin?
  end

  def render_user(user)
    render json: {
      user: {
        email: user.email,
        username: user.username,
        token: current_token,
        admin: user.admin?
      }
    }, status: :ok
  end
end
