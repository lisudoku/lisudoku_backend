def call_api(method, url, params = nil, user = nil)
  headers = {}
  headers = Devise::JWT::TestHelpers.auth_headers(headers, user) if user.present?

  case method
  when :get
    get url, params:, headers:, as: :json
  when :post
    post url, params:, headers:, as: :json
  when :delete
    delete url, params:, headers:, as: :json
  end
end

def get_api(url, user = nil)
  call_api(:get, url, nil, user)
end

def post_api(*args)
  call_api(:post, *args)
end

def delete_api(*args)
  call_api(:delete, *args)
end
