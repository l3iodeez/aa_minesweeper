require_relative './board'
require 'YAML'

class MineSweeperGame
  attr_reader :board

  def initialize
    difficulties = {
      0 => [9,9, 10],
      1 => [9,9, 10],
      2 => [16,16,40],
      3 => [16,30,99]
    }
    system('clear')
    diff_choice  = get_difficulty
    if diff_choice.downcase == "l"
      @board = load_game
    else
      diff_choice = diff_choice.to_i
      settings = difficulties[diff_choice]
      @board = MS_Board.new(*settings)
    end
    play_game
  end

  def get_difficulty
    puts "Choose a difficulty: (or L to load game)"
    puts "  1. Novice"
    puts "  2. Intermediate"
    puts "  3. Expert"
    return gets.chomp
  end

  def play_game
    until board.over?
      draw_screen

      pos = get_pos
      action = get_action
      board.make_move(pos, action)
    end
    if board.won?
      puts "YOU ROCK"
    else
      puts "YOU SUCK"
    end
  end

  def draw_screen
    system('clear')
    board.render
  end

  def get_pos
    puts "Enter a position as x,y:"
    input = gets.chomp
    save_game if input.downcase == "save"

    until parse(input).length == 2
      input = gets.chomp
    end
    parse(input)
  end

  def save_game
    puts "Enter a name for this save:"
    filename = gets.chomp.gsub(/[^\w\d]/,'') + ".yml"
    File.write("saves/#{filename}", board.to_yaml )
    puts "Game saved as #{filename}"
  end

  def load_game
    puts "Enter a filename to load:"
    filename = gets.chomp
    YAML.load_file("saves/#{filename}.yml")
  end

  def get_action
    puts "Enter 'R' for reveal or 'F' for flag:"
    action = gets.chomp.downcase[0]
    return :R unless action == "f"
    :F
  end

  def parse(input)
   input.gsub(/\D/,'').split('').map(&:to_i)
  end
end

if $PROGRAM_NAME == __FILE__
  game = MineSweeperGame.new
end
