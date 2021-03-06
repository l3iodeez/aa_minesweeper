require_relative 'tile.rb'
require 'colorize'
#require 'byebug'

class MS_Board

  def self.tile_display_list
    pipe = 
    tile_display_list = {
      0 => "   ".colorize(:color => :light_white, :background => :light_white),
      1 => " 1 ".colorize(:color => :blue, :background => :light_white),
      2 => " 2 ".colorize(:color => :green, :background => :light_white),
      3 => " 3 ".colorize(:color => :light_magenta, :background => :light_white),
      4 => " 4 ".colorize(:color => :magenta, :background => :light_white),
      5 => " 5 ".colorize(:color => :light_red, :background => :light_white),
      7 => " 7 ".colorize(:color => :red, :background => :light_white),
      8 => " 8 ".colorize(:color => :black, :background => :light_white),
      :bomb => " B ".colorize(:color => :black, :background => :red),
      :flag => " F ".colorize(:color => :red, :background => :light_white),
      :hidden => " * ".colorize(:color => :light_black, :background => :light_white),
      :line => "----".colorize(:color => :light_black, :background => :light_white),
      :space => " ".colorize(:color => :light_white, :background => :light_white),
      :pipe => "|".colorize(:color => :light_black, :background => :light_white)
    }
  end
  TILE_DISPLAY_LIST = MS_Board.tile_display_list


  attr_reader :grid
  attr_accessor :visited_positions, :cursor_pos

  def initialize(size_x = 10, size_y = 10, num_bombs = 10)

    @visited_positions = []
    @grid = Array.new(size_x){Array.new(size_y){MS_Tile.new}}
    place_bombs(num_bombs)
    @cursor_pos = [0,0]
  end

  def [](pos)
    x, y = pos
    grid[x][y]
  end

  def render
    puts TILE_DISPLAY_LIST[:space] + (TILE_DISPLAY_LIST[:line] * grid.first.length)
    grid.each_index do |idx|
      print TILE_DISPLAY_LIST[:pipe]
      grid.first.each_index do |idy|
        pos = [idx, idy]
        print_pos(pos)
      end
      puts
      puts TILE_DISPLAY_LIST[:space] + (TILE_DISPLAY_LIST[:line] * grid.first.length)
    end
    nil
  end

  def out_of_bounds?(pos)
    
      x, y = pos
      return true unless x.between?(0, grid.length - 1)
      return true unless y.between?(0, grid.first.length - 1)
      false
  end

  def make_move(pos, action)
    if action == :r
      reveal_pos(pos)
    else
      flag_pos(pos)
    end
  end

  def flag_pos(pos)
    tile = self[pos]
    tile.toggle_flag
  end

  def reveal_pos(pos)
    queue = [pos]
    visited_positions << pos
    until queue.empty?
      current_pos = queue.shift
      current_tile = self[current_pos]
      unless current_tile.flagged
        current_tile.reveal
        unless num_adjacent_bombs(current_pos) > 0
          adjacents = adjacent_non_visited(current_pos)
          queue += adjacents
          self.visited_positions += adjacents
        end
      end
    end
  end

  def adjacent_non_visited(pos)
    adjacent_positions(pos).reject{ |adj_pos| visited_positions.include?(adj_pos) }
  end

  def print_pos(pos)


    tile = self[pos]

    num_adjacent_bombs = num_adjacent_bombs(pos)
    if !tile.revealed
      if tile.flagged
        print cursor(TILE_DISPLAY_LIST[:flag],pos)
      else
        print cursor(TILE_DISPLAY_LIST[:hidden],pos)
      end
    else
      if tile.is_bomb
        print cursor(TILE_DISPLAY_LIST[:bomb],pos)
      else
        print cursor(TILE_DISPLAY_LIST[num_adjacent_bombs],pos) 
      end
    end
    print TILE_DISPLAY_LIST[:pipe]
    
  end
  def cursor(clr_string,pos)
    if pos == cursor_pos
      clr_string.white.on_black.blink
    else
      clr_string
    end
  end
  def num_adjacent_bombs(pos)
    adjacent_positions(pos).select { |adj_pos| self[adj_pos].is_bomb }.length
  end

  def adjacent_positions(pos)
    x, y = pos
    deltas = [
      [0,1],
      [1,1],
      [1,0],
      [0,-1],
      [-1,-1],
      [-1,0],
      [-1,1],
      [1,-1],
    ]
    deltas.map { |e| [x + e.first, y + e.last] }.reject {|pos| out_of_bounds?(pos)}
  end
  def reveal_bombs
    bombs = grid.flatten.select { |tile| tile.is_bomb }
    bombs.each { |tile| tile.reveal }
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
