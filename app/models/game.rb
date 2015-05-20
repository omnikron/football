class Game < ActiveRecord::Base
  has_many :players, through: :scores
  has_many :scores
  has_many :notes
  default_scope { includes(:scores, :notes) }
  accepts_nested_attributes_for :scores

  after_initialize :setup_scores

  class << self
    def total_score(games = nil)
      games = games.present? ? self.where(id: games.map(&:id)) : all

      Player.all.inject({}) do |hash, player|
        hash[player] = games.score_for(player)
        hash
      end
    end

    def score_for(player)
      joins(:scores).where(scores: {player: player}).sum(:score)
    end

    def no_notes
      joins('LEFT OUTER JOIN notes ON notes.game_id = games.id').where('notes.game_id IS NULL')
    end

    def draws
      all.select {|g| g.draw? }
    end

    def last_win
      (all - draws).last
    end

    def wins_by(player)
      player = player.is_a?(Player) ? player : Player.find_by_name(player)
      player.wins
    end

    def losses_by(player)
      player = player.is_a?(Player) ? player : Player.find_by_name(player)
      player.losses
    end

    def biggest_wins(count = 1)
      all.sort_by {|g| g.scores.order('score DESC').first.score - g.scores.order('score DESC').last.score }.last(count).reverse
    end
  end

  def note(body)
    notes.create(body: body)
  end

  def score(player)
    player = player.is_a?(Player) ? player : Player.find_by_name(player)
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
    if new_record? && scores.blank?
      Player.all.each do |p|
        scores.build(player: p)
      end
    end
  end
end
