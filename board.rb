require_relative 'piece.rb'

class NilClass
  def [](input)
  	nil
  end

  def disp
    nil
  end

  def rank
  	nil
  end

  def team
  	nil
  end

  def to_sym
  	nil
  end
end
#--------TO DO STILL--------
#2. en passant
#1. saving
#3. need to end game when stalemate occurs
#---------------------------
class Board
  attr_accessor :board, :letter_converter, :image_converter, :num_converter, :turn, :bking_moved, :bk_rook_moved, :bq_rook_moved, :wking_moved, :wk_rook_moved, :wq_rook_moved, :bking_x, :bking_y, :wking_x, :wking_y

  def initialize
  	#makes the board
  	@board = []
  	@board << create_power("black").dup
  	@board << create_pawns("black").dup
  	4.times { @board << [] }
  	@board << create_pawns("white").dup
  	@board << create_power("white").dup
  	@turn = 1
  	@bking_x, @bking_y = 0, 4
  	@wking_x, @wking_y = 7, 4
  	#some useful conversion hashes
  	@num_converter = { 1 => 7, 2 => 6, 3 => 5, 4 => 4, 5 => 3, 6 => 2, 7 => 1, 8 => 0 }
  	@letter_converter = { a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7 }
  	@image_converter = { nil => " ", pb: "\u265F", rb: "\u265C", nb: "\u265E", bb: "\u265D", qb: "\u265B", kb: "\u265A", pw: "\u2659", nw: "\u2658", bw: "\u2657", rw: "\u2656", qw: "\u2655", kw: "\u2654"}
  end

  def create_pawns(team)
  	pawns = []
  	8.times { pawns << Piece.new("pawn", team, "p" + team[0]) }
  	pawns
  end

  def create_power(team)
  	power = []
  	power << Piece.new("rook", team, "r" + team[0])
  	power << Piece.new("knight", team, "n" + team[0])
  	power << Piece.new("bishop", team, "b" + team[0])
  	power << Piece.new("queen", team, "q" + team[0])
  	power << Piece.new("king", team, "k" + team[0])
  	power << Piece.new("bishop", team, "b" + team[0])
  	power << Piece.new("knight", team, "n" + team[0])
  	power << Piece.new("rook", team, "r" + team[0])
  end

  def display_board
  	7.times do |row|
  	  print "\n\t\t#{8-row} "
  	  7.times do |col| 
  	  	print " #{image_converter[board[row][col].disp.to_sym]} |" 
  	  end
  	  print " #{image_converter[board[row][7].disp.to_sym]}"
  	  print "\n\t\t  ---"
  	  7.times { print "+---" }
  	end
  	print "\n\t\t1 "
  	7.times { |col| print " #{image_converter[board[7][col].disp.to_sym]} |" }
  	print " #{image_converter[board[7][7].disp.to_sym]}"
  	puts "\n\t\t   a   b   c   d   e   f   g   h"
  	unless checkmate?
  	  puts "Black's king in check" if king_in_check?("black")
  	  puts "White's king in check" if king_in_check?("white")
  	end
  end

  def move(start_coord, end_coord)
  	y1 = letter_converter[start_coord[0].to_sym]
  	x1 = num_converter[start_coord[1].to_i] 
  	y2 = letter_converter[end_coord[0].to_sym]
  	x2 = num_converter[end_coord[1].to_i]

  	if castling?(x1, y1, x2, y2, board[x1][y1].team)
  	  @turn = (turn == 1 ? 0 : 1)
  	  return true
  	end

    unless valid_play?(x1, y1, x2, y2)
      puts "Invalid Play"
      return false
    end
  	temp, board[x2][y2], board[x1][y1] = board[x2][y2], board[x1][y1], nil
  	update_king(x2, y2)

  	if king_in_check?(board[x2][y2].team)
  	  puts "Cannot leave your king in check"
  	  board[x1][y1], board[x2][y2] = board[x2][y2], temp
  	  update_king(x1, y1)
  	  return false
  	end
  	promote_pawn(x2, y2, board[x2][y2].team) if board[x2][y2].rank == "pawn" && (x2 == 7 || x2 == 0)
  	#castling stuff
  	@bking_moved = true if board[x2][y2].disp == "kb"
  	@wking_moved = true if board[x2][y2].disp == "kw"
  	@bk_rook_moved = true if x1 == 0 && y1 == 7
  	@bq_rook_moved = true if x1 == 0 && y1 == 0
  	@wk_rook_moved = true if x1 == 7 && y1 == 7
  	@wq_rook_moved = true if x1 == 7 && y1 == 0
  	puts "white queen rook: #{wq_rook_moved}"

  	@turn = (turn == 1 ? 0 : 1)
  	true
  end

  def update_king(x, y)
  	@bking_x, @bking_y = x, y if board[x][y].disp == "kb"
  	@wking_x, @wking_y = x, y if board[x][y].disp == "kw"
  end

  def promote_pawn(x, y, team)
  	puts "Choose Q B R K to promote your pawn: "
  	promotion = gets.chomp
  	case promotion
  	when "Q" then board[x][y] = Piece.new("queen", team, "q" + team[0])
  	when "B" then board[x][y] = Piece.new("bishop", team, "b" + team[0])
  	when "R" then board[x][y] = Piece.new("rook", team, "r" + team[0])	
  	when "K" then board[x][y] = Piece.new("knight", team, "n" + team[0])
  	else board[x][y] = Piece.new("queen", team, "q" + team[0])
  	end
  end

  def valid_play?(x1, y1, x2, y2)
	return false if board[x1][y1].nil?
	return false if x1 == x2 && y1 == y2
	return false if (turn == 1 && board[x1][y1].team == "black") || (turn == 0 && board[x1][y1].team == "white")
	return false if board[x1][y1].team == board[x2][y2].team

  	case board[x1][y1].rank
  	when "pawn" then return false unless valid_pawn_play?(x1, y1, x2, y2, board[x1][y1].team)
  	when "rook" then return false unless valid_rook_play?(x1, y1, x2, y2)
  	when "knight" then return false unless valid_knight_play?(x1, y1, x2, y2)
  	when "bishop" then return false unless valid_bishop_play?(x1, y1, x2, y2)
  	when "queen" then return false unless valid_rook_play?(x1, y1, x2, y2) || valid_bishop_play?(x1, y1, x2, y2)
  	when "king" then return false unless valid_king_play?(x1, y1, x2, y2)
  	end
  	true
  end

  def valid_pawn_play?(x1, y1, x2, y2, team)
  	#pawn is not attacking
  	if board[x2][y2].nil? 
  	  return false unless y1 == y2
  	  if team == "black"
  	  	#double step
  	  	return true if x1 == 1 && x2 == 3
	    return false unless x2 == x1 + 1
  	  elsif team == "white"
  	  	#double step
  	  	return true if x1 == 6 && x2 == 4
  	  	return false unless x2 == x1 - 1
  	  end
  	#pawn is attacking
  	else
  	  return false unless y2 == y1 + 1 || y2 == y1 - 1
  	  if team == "black"
  	  	return false unless x2 == x1 + 1
  	  elsif team == "white"
  	  	return false unless x2 == x1 - 1
  	  end
  	end
  	true
  end

  def valid_rook_play?(x1, y1, x2, y2)
  	return false if x1 != x2 && y1 != y2
  	if x1 != x2
  	  (x1+1...x2).each { |x| return false unless board[x][y1].nil? }
  	  (x2+1...x1).each { |x| return false unless board[x][y1].nil? }
  	else
  	  (y1+1...y2).each { |y| return false unless board[x1][y].nil? }
  	  (y2+1...y1).each { |y| return false unless board[x1][y].nil? }
  	end
  	true
  end

  def valid_bishop_play?(x1, y1, x2, y2)
  	return false if x1 == x2 || y1 == y2
  	#check the slope of the path line to determine if valid move
  	return false unless ((y2 - y1)/(x2 - x1).to_f).abs == 1
  	#checks travel path for pieces
  	i = (x2 - x1).abs - 1
  	if x1 > x2
  	  if y1 > y2
  	  	i.times { |k| return false unless board[x1 - (k+1)][y1 - (k+1)].nil? }
  	  else
  	  	i.times { |k| return false unless board[x1 - (k+1)][y1 + (k+1)].nil? }
  	  end
  	else
  	  if y1 > y2
  	  	i.times { |k| return false unless board[x1 + (k+1)][y1 - (k+1)].nil? }
  	  else
  	  	i.times { |k| return false unless board[x1 + (k+1)][y1 + (k+1)].nil? }
  	  end
  	end
  	true
  end

  def valid_knight_play?(x1, y1, x2, y2)
  	return true if ((x2 - x1).abs == 1 && (y2 - y1).abs == 2) || ((x2 - x1).abs == 2 && (y2 - y1).abs == 1)
  	false
  end

  def valid_king_play?(x1, y1, x2, y2)
  	return false unless ((x2 - x1)).abs <= 1 && ((y2 - y1)).abs <= 1
  	true
  end

  def castling?(x1, y1, x2, y2, team)
  	return false unless board[x1][y1].rank == "king"
  	return false unless (y1 - y2).abs == 2 && x1 == x2
	return false if (turn == 1 && board[x1][y1].team == "black") || (turn == 0 && board[x1][y1].team == "white")
  	if team == "white"
  	  return false if wking_moved
  	  return false if king_in_check?("white")
  	  if y2 == 6
  	  	return false if wk_rook_moved
  	  	(y1+1..y2).each { |y| return false if moving_into_check?(x1, y, "white") || board[x1][y] }
  	  	castle_kingside(x1)
  	  elsif y2 == 2
  	  	return false if wq_rook_moved
  	  	(y2...y1).each { |y| return false if moving_into_check?(x1, y, "white") || board[x1][y] }
  	  	return false if board[x1][1]
  	  	castle_queenside(x1)
  	  end
  	else
  	  return false if bking_moved
  	  return false if king_in_check?("black")
  	  if y2 == 6
  	  	return false if bk_rook_moved
  	  	(y1+1..y2).each { |y| return false if moving_into_check?(x1, y, "black") || board[x1][y] }
  	  	castle_kingside(x1)
  	  elsif y2 == 2
  	  	return false if bq_rook_moved
  	  	(y2...y1).each { |y| return false if moving_into_check?(x1, y, "black") || board[x1][y] }
  	  	return false if board[x1][1]
  	  	castle_queenside(x1)
  	  end
  	end
  	true 
  end

  def castle_kingside(x)
  	board[x][5] = board[x][7]
  	board[x][6] = board[x][4]
  	board[x][4] = nil
  	board[x][7] = nil
  	update_king(x, 6)
  end

  def castle_queenside(x)
  	board[x][3] = board[x][0]
  	board[x][2] = board[x][4]
  	board[x][4] = nil
  	board[x][0] = nil
  	update_king(x, 2)
  end

  def king_in_check?(team)
    return (team == "white" ? moving_into_check?(wking_x, wking_y, team) : moving_into_check?(bking_x, bking_y, team))
  end
  
  def moving_into_check?(x, y, team)
  	@turn = (turn == 1 ? 0 : 1)
  	8.times do |x1|
  	  8.times do |y1| 
  	    if valid_play?(x1, y1, x, y) && board[x1][y1].team != team 
  	      @turn = (turn == 1 ? 0 : 1)
  	      return true
  	    end
  	  end
  	end
  	@turn = (turn == 1 ? 0 : 1)
  	false
  end

  def checkmate?
  	king = turn == 1 ? board[wking_x][wking_y] : board[bking_x][bking_y]
  	return false unless king_in_check?(king.team)
  	8.times do |x1|
  	  8.times do |y1|
  	  	if board[x1][y1].team == king.team
  	  	  8.times do |x2|
  	  	  	8.times do |y2|
  	  	  	  next unless valid_play?(x1, y1, x2, y2)
  	  	  	  temp, board[x2][y2], board[x1][y1] = board[x2][y2], board[x1][y1], nil
  	  	  	  update_king(x2, y2)
  	  	  	  unless king_in_check?(king.team)
  	  	  	  	board[x1][y1], board[x2][y2] = board[x2][y2], temp
  	  	  	  	update_king(x1, y1)
  	  	  	  	return false
  	  	  	  end
  	  	  	  board[x1][y1], board[x2][y2] = board[x2][y2], temp
  	  	  	  update_king(x1, y1)
  	  	  	end
  	  	  end
  	  	end
  	  end
  	end
  	puts "#{king.team}'s king has been mated!"
    true
  end

end













