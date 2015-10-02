require 'io/console'

# Reads keypresses from the user including 2 and 3 escape character sequences.
def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end

# oringal case statement from:
# http://www.alecjacobson.com/weblog/?p=75
def show_single_key
  c = read_char

  case c
  when " "
    return "SPACE"
  when "\t"
    return "TAB"
  when "\r"
    return "RETURN"
  when "\n"
    return "LINE FEED"
  when "\e"
    return "ESCAPE"
  when "\e[A"
    return "UP ARROW"
  when "\e[B"
    return "DOWN ARROW"
  when "\e[C"
    return "RIGHT ARROW"
  when "\e[D"
    return "LEFT ARROW"
  when "\177"
    return "BACKSPACE"
  when "\004"
    return "DELETE"
  when "\e[3~"
    return "ALTERNATE DELETE"
  when "\u0003"
    return "CONTROL-C"
    exit 0
  when /^.$/
    return "SINGLE CHAR HIT: #{c.inspect}"
  else
    return "SOMETHING ELSE: #{c.inspect}"
  end
end
