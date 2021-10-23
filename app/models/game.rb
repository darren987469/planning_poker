class Game < ApplicationRecord
  has_many :votes
  has_many :users, through: :votes

  enum status: { not_started: 'not_started', voting: 'voting', voting_ended: 'voting_ended' }

  STATUS_CHANGE_MAP = {
    'not_started' => 'voting',
    'voting' => 'voting_ended',
    'voting_ended' => 'voting'
  }.freeze

  validates :name, presence: true
  validate :validate_status_change, if: -> { status_changed? }

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

  def validate_status_change
    valid_status = STATUS_CHANGE_MAP[status_was]
    return if status == valid_status

    errors.add(:base, 'invalid game status change')
  end
end
