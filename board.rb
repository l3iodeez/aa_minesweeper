require_relative 'tile.rb'
require 'byebug'

class MS_Board

  attr_reader :grid, :visited_positions

  def initialize(size_x = 10, size_y = 10)
    @visited_positions = []
    @grid = Array.new(size_x){Array.new(size_y){MS_Tile.new}}
    place_bombs(size_x)
  end

  def [](pos)
    x, y = pos
    grid[x][y]
  end

  def render
    puts " " + ("----" * grid.first.length)
    grid.each_index do |idx|
      print "|"
      grid.first.each_index do |idy|
        pos = [idx, idy]
        print_pos(pos)
      end
      puts
      puts " " + ("----" * grid.first.length)
    end
    nil
  end

  def out_of_bounds?(pos)
      x, y = pos
      return true unless x.between?(0, grid.length - 1)
      return true unless y.between?(0, grid.first.length - 1)
      false
  end

  def reveal_pos(pos)
    queue = [pos]

    until queue.empty?

      current_pos = queue.shift
      visited_positions << current_pos
      current_tile = self[current_pos]
      unless current_tile.flagged
        current_tile.reveal
        unless num_adjacent_bombs(current_pos) > 0
          adjacent_positions = adjacent_positions(current_pos)
          queue += adjacent_positions.reject{ |adj_pos| visited_positions.include?(adj_pos) }
        end
      end
    end

end

  def print_pos(pos)
    tile = self[pos]

    display_list = (0..8).to_a.map! { |index| " #{index} |" }
    display_list[0] = "   |"

    num_adjacent_bombs = num_adjacent_bombs(pos)
    if !tile.revealed
      print " * |"
    else
      if tile.is_bomb
        print " B |"
      else
        print display_list[num_adjacent_bombs]
      end
    end
  end

  def num_adjacent_bombs(pos)
    adjacent_positions(pos).select { |adj_pos| self[adj_pos].is_bomb }.length
  end

  def adjacent_positions(pos)
    x, y = pos
    vectors = [
      [0,1],
      [1,1],
      [1,0],
      [0,-1],
      [-1,-1],
      [-1,0],
      [-1,1],
      [1,-1],
    ]
    vectors.map { |e| [x + e.first, y + e.last] }.reject {|pos| out_of_bounds?(pos)}
  end

  def bomb_count
    grid.flatten.select { |tile| tile.is_bomb }.count
  end

  def place_bomb(pos)
    tile = self[pos]
    tile.is_bomb = true
  end

  def place_bombs(number)
    until bomb_count == number
      place_random_bomb
    end
  end

  def place_random_bomb
    random_pos = [rand(grid.length), rand(grid.first.length)]
    place_bomb(random_pos)
  end

  def over?
    lost? || won?
  end

  def won?
    non_bombs = grid.flatten.reject { |tile| tile.is_bomb }
    non_bombs.all? {|tile| tile.revealed }
  end

  def lost?
    grid.flatten.any? { |tile| tile.is_bomb && tile.revealed }
  end

end

if $PROGRAM_NAME == __FILE__
  b = MS_Board.new
  b.render
end
