require 'yaml'

class Coord
	attr_accessor :x, :y

	def initialize(x,y)
		@x = x
		@y = y
	end

end

class Player
	attr_reader :color, :name
	attr_accessor	:pieces, :check

	def initialize (color, name)
		@color = color
		@name = name
		@pieces = Piece.starting_pieces(color)
		@check = false
	end

end

class Piece
	attr_accessor :name, :status, :color, :position

	def initialize(name, position, color)
		@name = name
		@position = position
		@status = :alive
		@color = color
	end

	def Piece.starting_pieces(color)
		if color == :white
			start_row = 1
			pawn_row = 2
		else
			start_row = 8
			pawn_row = 7
		end
		pieces = []
		#pawns
		for i in 1..8
			pieces << Piece.new(:pawn, Coord.new(i,pawn_row), color)
			if i == 1 || i == 8
				pieces << Piece.new(:rook, Coord.new(i,start_row), color)
			end
			if i == 2 || i == 7
				pieces << Piece.new(:knight, Coord.new(i,start_row), color)
			end
			if i == 3 || i == 6
				pieces << Piece.new(:bishop, Coord.new(i,start_row), color)
			end
			if i == 4
				pieces << Piece.new(:queen, Coord.new(i,start_row), color)
			end
			if i == 5
				pieces << Piece.new(:king, Coord.new(i,start_row), color)
			end
		end
		pieces
	end

end

class Board
	attr_accessor :state, :white_player, :black_player
	def initialize
		@white_player = Player.new(:white, "White")
		@black_player = Player.new(:black, "Black")
		@state = initial_state
	end

	def empty_state
		row = Array.new(8)
		table = []
		8.times do
			table << Array.new(8)
		end
		table.transpose
	end

	def initial_state
		init = empty_state
		@white_player.pieces.each {|piece|
			init[(piece.position.x-1)][(piece.position.y-1)] = piece
		}
		@black_player.pieces.each {|piece|
			init[(piece.position.x-1)][(piece.position.y-1)] = piece
		}
		init
	end

	def print_state
		to_print = @state.transpose
		to_print.reverse.each_with_index {|row, i|
			alpha_headers = 'a'..'h'
			print alpha_headers.to_a[alpha_headers.to_a.length - i - 1] + " "
			row.each {|piece|
				if piece.nil?
					print "* "
				else
					case piece.name
					when :pawn
						print "♙ " if piece.color == :white
						print "♟ " if piece.color == :black
					when :rook
						print "♖ " if piece.color == :white
						print "♜ " if piece.color == :black
					when :bishop
						print "♗ " if piece.color == :white
						print "♝ " if piece.color == :black
					when :knight
						print "♘ " if piece.color == :white
						print "♞ " if piece.color == :black
					when :king
						print "♔ " if piece.color == :white
						print "♚ " if piece.color == :black
					when :queen
						print "♕ " if piece.color == :white
						print "♛ " if piece.color == :black
					else
						raise RuntimeError
					end
				end
			}
			puts
		}
		print "  "
		int_headings = (1..8).to_a.each{|i| print "#{i} "}
		puts
	end

	def on_board?(x,y)
		x >= 0 && x <= 7 && y >= 0 && y <= 7
	end

	#returns array of trues and nils corresponding to legal/illegal moves
	def legal_move(piece)
		possible_moves = empty_state
		x = piece.position.x
		y = piece.position.y
		case piece.name
		when :pawn
			if piece.color == :white
				#forward
				if on_board?(x-1,y) && @state[x-1][y].nil?
					possible_moves[x-1][y] = true
				end
				#diagonals
				if on_board?(x,y)
					possible_moves[x][y] = true if !@state[x][y].nil? && !@state[x][y].color != piece.color
				end
				if on_board?(x-2,y)
					possible_moves[x-2][y] = true if !@state[x-2][y].nil? && !@state[x-2][y].color != piece.color
				end
			else #black
				#forward
				if on_board?(x-1,y-2) && @state[x-1][y-2].nil?
					possible_moves[x-1][y-2] = true
				end
				#diagonals
				if on_board?(x,y-2)
					possible_moves[x][y-2] = true if !@state[x][y-2].nil? && !@state[x][y-2].color != piece.color
				end
				if on_board?(x-2,y-2)
					possible_moves[x-2][y-2] = true if !@state[x-2][y-2].nil? && !@state[x-2][y-2].color != piece.color
				end
			end

		#MUST replace @state[x][y] with on_board?(x,y)... Same with bishop.
		when :rook
			#up-down
			up_bound = y
			low_bound = y-2
			while up_bound <= 7 && @state[x-1][up_bound].nil?
				possible_moves[x-1][up_bound] = true
				up_bound += 1
			end
			if on_board?(x-1,up_bound) && !@state[x-1][up_bound].nil? && @state[x-1][up_bound].color != piece.color
				possible_moves[x-1][up_bound] = true
			end
			while low_bound >= 0 && @state[x-1][low_bound].nil?
				possible_moves[x-1][low_bound] = true
				low_bound -= 1
			end
			if on_board?(x-1,low_bound) && !@state[x-1][low_bound].nil? && @state[x-1][low_bound].color != piece.color
				possible_moves[x-1][low_bound] = true
			end
			#left-right
			left_bound = x - 2
			right_bound = x
			while right_bound <= 7 && @state[right_bound][y-1].nil?
				possible_moves[right_bound][y-1] = true
				right_bound += 1
			end
			if on_board?(right_bound,y-1) && !@state[right_bound][y-1].nil? && @state[right_bound][y-1].color != piece.color
				possible_moves[right_bound][y-1] = true
			end
			while left_bound >= 0 && @state[left_bound][y-1].nil?
				possible_moves[left_bound][y-1] = true
				left_bound -= 1
			end
			if on_board?(left_bound,y-1) && !@state[left_bound][y-1].nil? && @state[left_bound][y-1].color != piece.color
				possible_moves[left_bound][y-1] = true
			end
		when :bishop
			up_bound_y = y
			low_bound_y = y-2
			up_bound_x = x
			low_bound_x = x-2
			while low_bound_x >= 0 && up_bound_y <= 7  && @state[low_bound_x][up_bound_y].nil?
				possible_moves[low_bound_x][up_bound_y] = true
				low_bound_x += -1
				up_bound_y += 1
			end
			if on_board?(low_bound_x,up_bound_y) && !@state[low_bound_x][up_bound_y].nil? && @state[low_bound_x][up_bound_y].color != piece.color
				possible_moves[low_bound_x][up_bound_y] = true
			end
			low_bound_x = x-2
			up_bound_y = y
			while low_bound_x >= 0 && low_bound_y >= 0  && @state[low_bound_x][low_bound_y].nil?
				possible_moves[low_bound_x][low_bound_y] = true
				low_bound_x += -1
				low_bound_y += -1
			end
			if on_board?(low_bound_x,low_bound_y) && !@state[low_bound_x][low_bound_y].nil? && @state[low_bound_x][low_bound_y].color != piece.color
				possible_moves[low_bound_x][low_bound_y] = true
			end
			up_bound_x = x
			low_bound_y = y-2
			while up_bound_x <= 7 && low_bound_y >= 0 && @state[up_bound_x][low_bound_y].nil?
				possible_moves[up_bound_x][low_bound_y] = true
				up_bound_x += 1
				low_bound_y += -1
			end
			if on_board?(up_bound_x,low_bound_y) && !@state[up_bound_x][low_bound_y].nil? && @state[up_bound_x][low_bound_y].color != piece.color
				possible_moves[up_bound_x][low_bound_y] = true
			end
			up_bound_x = x
			up_bound_y = y
			while up_bound_x <= 7 && up_bound_y <= 7 && @state[up_bound_x][up_bound_y].nil?
				possible_moves[up_bound_x][up_bound_y] = true
				up_bound_x += 1
				up_bound_y += 1
			end
			if on_board?(up_bound_x,up_bound_y) && !@state[up_bound_x][up_bound_y].nil? && @state[up_bound_x][up_bound_y].color != piece.color
				possible_moves[up_bound_x][up_bound_y] = true
			end
		when :knight
			for i in -2..2
				for j in -2..2
					if i.abs + j.abs == 3
						if on_board?(x-1-i,y-1-j)
							if @state[x-1-i][y-1-j].nil? || @state[x-1-i][y-1-j].color != piece.color
								possible_moves[x-1-i][y-1-j] = true
							end
						end
					end
				end
			end
		#need to add castling
		when :king
			for i in -1..1
				for j in -1..1
					if on_board?(x-1-i,y-1-j)
						if @state[x-1-i][y-1-j].nil? || @state[x-1-i][y-1-j].color != piece.color
							possible_moves[x-1-i][y-1-j] = true
						end
					end
				end
			end
			possible_moves[x-1][y-1]= nil
		when :queen
			#up-down
			up_bound = y
			low_bound = y-2
			while up_bound <= 7 && @state[x-1][up_bound].nil?
				possible_moves[x-1][up_bound] = true
				up_bound += 1
			end
			if on_board?(x-1,up_bound) && !@state[x-1][up_bound].nil? && @state[x-1][up_bound].color != piece.color
				possible_moves[x-1][up_bound] = true
			end
			while low_bound >= 0 && @state[x-1][low_bound].nil?
				possible_moves[x-1][low_bound] = true
				low_bound -= 1
			end
			if on_board?(x-1,low_bound) && !@state[x-1][low_bound].nil? && @state[x-1][low_bound].color != piece.color
				possible_moves[x-1][low_bound] = true
			end
			#left-right
			left_bound = x - 2
			right_bound = x
			while right_bound <= 7 && @state[right_bound][y-1].nil?
				possible_moves[right_bound][y-1] = true
				right_bound += 1
			end
			if on_board?(right_bound,y-1) && !@state[right_bound][y-1].nil? && @state[right_bound][y-1].color != piece.color
				possible_moves[right_bound][y-1] = true
			end
			while left_bound >= 0 && @state[left_bound][y-1].nil?
				possible_moves[left_bound][y-1] = true
				left_bound -= 1
			end
			if on_board?(left_bound,y-1) && !@state[left_bound][y-1].nil? && @state[left_bound][y-1].color != piece.color
				possible_moves[left_bound][y-1] = true
			end

			up_bound_y = y
			low_bound_y = y-2
			up_bound_x = x
			low_bound_x = x-2
			while low_bound_x >= 0 && up_bound_y <= 7  && @state[low_bound_x][up_bound_y].nil?
				possible_moves[low_bound_x][up_bound_y] = true
				low_bound_x += -1
				up_bound_y += 1
			end
			if on_board?(low_bound_x,up_bound_y) && !@state[low_bound_x][up_bound_y].nil? && @state[low_bound_x][up_bound_y].color != piece.color
				possible_moves[low_bound_x][up_bound_y] = true
			end
			low_bound_x = x-2
			up_bound_y = y
			while low_bound_x >= 0 && low_bound_y >= 0  && @state[low_bound_x][low_bound_y].nil?
				possible_moves[low_bound_x][low_bound_y] = true
				low_bound_x += -1
				low_bound_y += -1
			end
			if on_board?(low_bound_x,low_bound_y) && !@state[low_bound_x][low_bound_y].nil? && @state[low_bound_x][low_bound_y].color != piece.color
				possible_moves[low_bound_x][low_bound_y] = true
			end
			up_bound_x = x
			low_bound_y = y-2
			while up_bound_x <= 7 && low_bound_y >= 0 && @state[up_bound_x][low_bound_y].nil?
				possible_moves[up_bound_x][low_bound_y] = true
				up_bound_x += 1
				low_bound_y += -1
			end
			if on_board?(up_bound_x,low_bound_y) && !@state[up_bound_x][low_bound_y].nil? && @state[up_bound_x][low_bound_y].color != piece.color
				possible_moves[up_bound_x][low_bound_y] = true
			end
			up_bound_x = x
			up_bound_y = y
			while up_bound_x <= 7 && up_bound_y <= 7 && @state[up_bound_x][up_bound_y].nil?
				possible_moves[up_bound_x][up_bound_y] = true
				up_bound_x += 1
				up_bound_y += 1
			end
			if on_board?(up_bound_x,up_bound_y) && !@state[up_bound_x][up_bound_y].nil? && @state[up_bound_x][up_bound_y].color != piece.color
				possible_moves[up_bound_x][up_bound_y] = true
			end
		else
			raise RunTimeError, "Invalid piece name"
		end
		possible_moves
	end

	def merge_legal_moves(l1,l2)
		new_moves = l1
		for i in 0..7
			for j in 0..7
				new_moves[i][j] = true if l1[i][j] || l2[i][j]
			end
		end
		new_moves
	end

	def legal_moves(player)
		legal = empty_state
		player.pieces.each { |piece|
			if piece.status == :alive
				legal = merge_legal_moves(legal,legal_move(piece))
			end
		}
		legal
	end

	def pawn_upgrade(piece)
		valid_pieces = [:rook, :bishop, :knight, :queen]
		begin
			puts "What would you like to upgrade your pawn into?"
			puts "Rook, bishop, knight, queen"
			new_name = gets.chomp.to_sym
			if valid_pieces.include?(new_name)
				piece.name = new_name
			else
				raise ArgumentError
			end
		rescue
			puts "Invald input. Try again."
			retry
		end
	end

	#throws an error for invalid moves
	def move_piece(c1,c2)
		raise ArgumentError, "Invalid coordinates" if !on_board?(c1.x-1,c1.y-1) || !on_board?(c2.x-1,c2.y-1)
		piece = @state[c1.x-1][c1.y-1]
		if piece.nil?
			raise ArgumentError, "no piece to move"
		else
			if legal_move(piece)[c2.x-1][c2.y-1]
				#Capture piece
				if !@state[c2.x-1][c2.y-1].nil?
					@state[c2.x-1][c2.y-1].status = :captured
				end
				#Move piece
				old_piece = @state[c2.x-1][c2.y-1]
				@state[c2.x-1][c2.y-1] = piece
				piece.position = Coord.new(c2.x,c2.y)
				@state[c1.x-1][c1.y-1] = nil
				#if under check, reverse moves and raise ArgumentError
				if piece.color == :white
					pos = @white_player.pieces.select{|piece| piece.name == :king}.first.position
					if legal_moves(@black_player)[pos.x-1][pos.y-1] == true
						if !old_piece.nil?
							old_piece.status = :alive
						end
						@state[c2.x-1][c2.y-1] = old_piece
						@state[c1.x-1][c1.y-1] = piece
						piece.position = Coord.new(c1.x,c1.y)
						raise ArgumentError, "Can't do that. You're under check!"
					end
				else
					pos = @black_player.pieces.select{|piece| piece.name == :king}.first.position
					if legal_moves(@white_player)[pos.x-1][pos.y-1] == true
						if !old_piece.nil?
							old_piece.status = :alive
						end
						@state[c2.x-1][c2.y-1] = old_piece
						@state[c1.x-1][c1.y-1] = piece
						piece.position = Coord.new(c1.x,c1.y)
						raise ArgumentError, "Can't do that. You're under check!"
					end
				end
				#pawn upgrade
				if piece.name == :pawn
					pawn_upgrade(piece) if piece.color == :white && c2.y == 8
					pawn_upgrade(piece) if piece.color == :black && c2.y == 1
				end
			else
				raise ArgumentError, "Can't move there"
			end
		end
	end

end

class Game
	attr_accessor :board, :current_player, :other_player
	def initialize
		main
	end

	def char_to_i(c)
		("a".."z").to_a.index(c.downcase) + 1
	end

	def save_game
		puts "Name of saved file?"
		file_name = gets.chomp
		game_file = YAML.dump(self)
		File.open(file_name,'w+') do |file|
  		file.puts game_file
		end
	end

	def load_game(file)
		game_file = YAML.load_file(file)
		@board = game_file.board
		@current_player = game_file.current_player
		@other_player = game_file.other_player
	end

	def start_game
		puts "Enter one of the following:"
		puts "1) New game"
		puts "2) Load game"
		input = gets.to_i
		if input == 1
			new_game
		elsif input == 2
			puts "Enter file name to load"
			to_load = gets.chomp
			load_game(to_load)
		else
			puts "Invalid input. Try again."
			start_game
		end
	end

	def new_game
		@board = Board.new
		@current_player = @board.white_player
		@other_player = @board.black_player
	end

	def choose_coord(input)
		if ('a'..'z').cover?(input[0]) && (input[1].to_i.is_a? Integer) && input.length == 2
			y = char_to_i(input[0])
			x = input[1].to_i
			raise ArgumentError, "Coord not on board" if !@board.on_board?(x-1,y-1)
		else
			raise ArgumentError, "Invalid input. try again"
		end
		Coord.new(x,y)
	end

	def choose_piece(input)
		c1 = choose_coord(input)
		if @board.state[c1.x-1][c1.y-1].nil? || (@board.state[c1.x-1][c1.y-1].color != @current_player.color)
			raise ArgumentError, "Invalid piece. try again"
		else
			#show legal move highlighting
			c1
		end
	end

	def swap_players
		t = @current_player
		@current_player = @other_player
		@other_player = t
	end

	def check?
		#legal moves of other player encompass the current player's king's position
		pos = @current_player.pieces.select{|piece| piece.name == :king}.first.position
		legal_moves = @board.legal_moves(@other_player)
		if legal_moves[pos.x-1][pos.y-1] == true then
			@current_player.check = true
			true
		else
			@current_player.check = false
			false
		end
	end
	#wrong... this also needs to check if there is a way to remove the threat...
	def checkmate?
		check = check?
		return false if !check
		threatened_space = @board.legal_moves(@other_player)
		king = @current_player.pieces.select{|piece| piece.name == :king}.first
		king_moves = @board.legal_move(king)
		overlap = Array.new(@board.empty_state)
		for i in 0..7
			for j in 0..7
				overlap[i][j] = king_moves[i][j] && threatened_space[i][j]
			end
		end
		possible_moves = @board.legal_moves(@current_player)
		threatening_pieces = []
		@other_player.pieces.each {|piece|
			if legal_move(piece)[king.position.x-1][king.position.y-1]
				threatening_pieces << piece
			end
		}
		#if more than one threatening piece then checkmate? No, not if king can remove one of the threats.
		#Double check: Only king can move/capture

		#Single check: Any other piece can move/capture

		#Methodology: Find piece(s) that can capture threatening piece(s), create hypothetical states, and
		#see if king is still in check

		#Probably need to change check to take in an argument of state.
		if overlap == king_moves && check
			true
		else
			false
		end
	end

	def user_command
		begin
			puts "Select piece to move or SAVE game"
			input = gets.downcase.chomp
			if input == "save"
				save_game
				puts "See you next time!"
			else
				c1 = choose_piece(input)
				puts "Choose a coordinate to move to."
				input2 = gets.downcase.chomp
				c2 = choose_coord(input2)
				@board.move_piece(c1,c2)
			end
		rescue ArgumentError => e
			puts e.message
			retry
		end
		input
	end

	def main
		start_game
		loop do
			@board.print_state
			if checkmate?
				puts "Game over! #{@other_player.name} wins."
				break
			end
			puts "You're under check!" if check?
			puts "#{@current_player.name}'s turn:"
			cmd = user_command
			break if cmd == "save"
			swap_players
		end
	end
end