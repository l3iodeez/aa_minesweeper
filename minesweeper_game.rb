require_relative './board'
require 'yaml'
require_relative './keypress'
require 'byebug'

class MineSweeperGame
  attr_reader :board, :difficulty

  def initialize
    difficulties = {
      0 => [9,9, 10],
      1 => [9,9, 10],
      2 => [16,16,40],
      3 => [16,30,99]
    }
    system('clear')
    @difficulty = get_difficulty
    if difficulty.downcase == "l"
      @board = load_game
    else
      @difficulty = difficulty.to_i
      settings = difficulties[difficulty]
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
    keep_playing = false

    until board.over?
      draw_screen
      give_instructions
      key_pressed = nil
      until key_pressed == "RETURN" || key_pressed == "SPACE" || key_pressed == "ESCAPE"
         key_pressed = show_single_key
        case key_pressed
           when "UP ARROW"
             board.cursor_pos[0] -=1 unless board.out_of_bounds?(board.cursor_pos[0] - 1)
           when "DOWN ARROW"
             board.cursor_pos[0] +=1 unless board.out_of_bounds?(board.cursor_pos[0] + 1)
           when "LEFT ARROW"
             board.cursor_pos[1] -=1 unless board.out_of_bounds?(board.cursor_pos[1] - 1)
           when "RIGHT ARROW"
             board.cursor_pos[1] +=1  unless board.out_of_bounds?(board.cursor_pos[1] + 1)
           when "TAB"
             save_game
           when "ESCAPE"
             abort
        end
         draw_screen
         give_instructions
      end

      pos = board.cursor_pos
      case key_pressed
        when "RETURN"
          action = :r
        when "SPACE"
          action = :f
      end


      board.make_move(pos, action)
    end
    board.reveal_bombs
    draw_screen
    if board.won?
      puts "YOU ROCK!!"
    else
      puts "Tough luck."
    end


  end

  def draw_screen
    system('clear')
    board.render
  end
  def give_instructions
    puts "Use arrow keys to select a position."
    puts "Press Enter to reveal a position"
    puts "Press Space to flag a position"
    puts "Press Tab to save game or ESC to quit."
  end

  def save_game
    puts "Enter a name for this save:"
    filename = gets.chomp.gsub(/[^\w\d]/,'') + ".yml"
    File.write("saves/#{filename}", board.to_yaml )
    puts "Game saved"
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
