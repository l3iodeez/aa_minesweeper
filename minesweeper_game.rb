require_relative './board'

class MineSweeperGame
  attr_reader :board

  def initialize
    difficulties = {
      0 => [15,15, 10],
      1 => [9,9, 10],
      2 => [16,16,40],
      3 => [16,30,99]
    }
    settings = difficulties[get_difficulty]
    @board = MS_Board.new(*settings)
    play_game
  end

  def get_difficulty
    puts "Choose a difficulty:"
    puts "  1. Novice"
    puts "  2. Intermediate"
    puts "  3. Expert"
    return gets.chomp.to_i
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
    until parse(input).length == 2
      input = gets.chomp
    end
    parse(input)
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
