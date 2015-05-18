class Player < ActiveRecord::Base
  has_many :games, through: :scores
  default_scope { order(:name) }
  has_many :scores

  def wins
    games.select {|g| g.winner == self }
  end

  def losses
    games.select {|g| g.loser == self }
  end

  def total_score
    scores.pluck(:score).sum
  end

  def longest_streaks(count = 1)
    streaks.sort_by {|streak| streak.length }.last(count)
  end

  def streaks
    games.inject([]) do |streaks, game|
      streaks << [] if streaks.empty?
      streak = streaks[-1]
      if game.winner == self || game.draw?
        streak << game
      else
        streaks << [] if streaks[-1].present?
      end
      streaks
    end
  end
end
