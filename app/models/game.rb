class Game < ActiveRecord::Base
  belongs_to :weapon_set
  belongs_to :map
  has_many :players, through: :scores
  has_many :scores
  has_many :notes
  default_scope { includes(:scores) }

  accepts_nested_attributes_for :scores

  after_initialize :setup_scores

  class << self
    def draws
      all.select {|g| g.draw? }
    end

    def wins_by(player_name)
      player = Player.find_by_name(player_name)
      all.select {|g| g.winner == player }
    end

    def losses_by(player_name)
      player = Player.find_by_name(player_name)
      all.select {|g| g.loser == player }
    end

    def biggest_win
      all.sort_by {|g| g.scores.order('score DESC').first.score - g.scores.order('score DESC').last.score }.last
    end
  end

  def note(body)
    notes.create(body: body)
  end

  def score(player_name)
    player = players.find_by_name(player_name)
    scores.where(player: player).first.score
  end

  def winner
    return nil if draw?
    scores.order('score DESC').first.player
  end

  def loser
    return nil if draw?
    scores.order('score DESC').last.player
  end

  def draw?
    scores.pluck(:score).uniq.count == 1
  end

  private
  def setup_scores
    if self.scores.blank?
      [Player.find_by_name('Paul'), Player.find_by_name('Oli')].each do |p|
        scores.build(player: p)
      end
    end
  end
end
