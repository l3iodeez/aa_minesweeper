require_relative './board'
require 'YAML'
require_relative './keypress'
require 'byebug'

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
      key_pressed = nil
      until key_pressed == "RETURN" || key_pressed == "SPACE" || key_pressed == "ESCAPE"
         key_pressed = show_single_key
        # debugger
         case key_pressed

           when "UP ARROW"
             board.cursor_pos[0] -=1
           when "DOWN ARROW"
             board.cursor_pos[0] +=1
           when "LEFT ARROW"
             board.cursor_pos[1] -=1
           when "RIGHT ARROW"
             board.cursor_pos[1] +=1
           when "TAB"
             save_game
           when "ESCAPE"
             abort
           else
             puts board.cursor_pos
         end
         draw_screen
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

    #input = gets.chomp
    # save_game if input.downcase == "save"
    #
    # until parse(input).length == 2
    #   input = gets.chomp
    # end
    # parse(input)
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
