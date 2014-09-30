require 'digest/sha1'

module MKS
  class User < ActiveRecord::Base
    has_many :sessions

    def update_password(password)
      self.password_digest = Digest::SHA1.hexdigest(password)
    end

    def has_password?(password)
      Digest::SHA1.hexdigest(password) == self.password_digest
    end
  end
end
