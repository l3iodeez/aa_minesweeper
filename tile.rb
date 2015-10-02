class MS_Tile
  attr_accessor :flagged
  attr_reader :is_bomb, :revealed

  def initialize
    @is_bomb = false
    @flagged = false
    @revealed = false
  end

  def reveal
    @revealed = true
  end

end
