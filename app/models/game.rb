class Game < ApplicationRecord
  has_many :votes
  has_many :users, through: :votes

  enum status: { not_started: 'not_started', voting: 'voting', voting_ended: 'voting_ended' }

  validates :name, presence: true

  before_create :set_code

  private

  def set_code
    self.code = code || generate_code
  end

  def generate_code
    loop do
      random_code = SecureRandom.hex(10)
      break random_code unless Game.where(code: random_code).exists?
    end
  end
end
