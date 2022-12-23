module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_id

    def connect
      self.user_id = "GUEST_#{SecureRandom.urlsafe_base64(15)}"
      puts "Connected, user_id=#{self.user_id}"
    end
  end
end
