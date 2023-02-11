module TokenGeneratable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token

    private

    def generate_token
      self.id = loop do
        random_token = SecureRandom.uuid
        break random_token unless self.class.exists?(id: random_token)
      end
    end
  end
end
