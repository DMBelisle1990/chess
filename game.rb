require_relative 'board.rb'

class Game
  #turn 1 is white
  attr_accessor :player1, :player2, :turn, :board

  def initialize
  	@board = Board.new
  	puts "Welcome to command line chess!"
  	puts "Enter player 1's name: "
  	@player1 = gets.chomp
  	puts "Enter player 2's name: "
  	@player2 = gets.chomp
  	@turn = 1
  	puts "Welcome #{player1} and #{player2}!"
  	puts "#{player1.capitalize} will play first as white."
  	puts "Input your plays as 2 seperate row/col pairs(Ex: a5 b6)"
  	puts "Press enter to continue"
  	trash = gets
  	play_game
  end

  def play_game
  	make_move until game_over?
  	board.display_board
  end

  def make_move
  	start, finish = 0, 0 
  	board.display_board
  	loop do
  	  puts turn == 1 ? "Enter your play #{player1}: " : "Enter your play #{player2}: "
  	  coords = gets.chomp.split(" ")
  	  start = coords[0]
  	  finish = coords[1]
  	  unless valid_input?(start, finish)
  	  	puts "Invalid entry.  Input as 2 row/col pairs(Ex: a5 b6)"
  	  	next
  	  end
  	  break if board.move(start, finish)
  	end
  	@turn = (turn == 1 ? 0 : 1)
  end

  def valid_input?(start, finish)
  	#makes sure moves are entered in the correct form
  	return false if start == nil || finish == nil
  	#checks for valid range of letters
    return false unless start[0] =~ /[a-h]/ && finish[0] =~ /[a-h]/
  	#checks for valid range of numbers
  	return false unless start[1] =~ /[1-8]/ && finish[1] =~ /[1-8]/
  	true
  end

  def game_over?
  	return true if board.checkmate?
  end

end

g = Game.new