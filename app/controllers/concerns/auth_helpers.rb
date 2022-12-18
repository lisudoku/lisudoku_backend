module AuthHelpers
  def current_token
    request.env['warden-jwt_auth.token']
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
