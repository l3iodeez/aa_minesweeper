class MS_Tile
  attr_accessor :flagged, :is_bomb, :revealed
  #attr_reader :revealed

  def initialize
    @is_bomb = false
    @flagged = false
    @revealed = false
  end

  def reveal
    @revealed = true
  end

end
