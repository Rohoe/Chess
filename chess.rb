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
	attr_accessor	:pieces

	def initialize (color, name)
		@color = color
		@name = name
		@pieces = Piece.starting_pieces(color)
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
	#NIL conditions are wrong. Nil or piece is your own. It's a legal move to capture a piece!
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
		when :rook
			#up-down
			up_bound = y
			low_bound = y-2
			while up_bound <= 7 && @state[x-1][up_bound].nil?
				possible_moves[x-1][up_bound] = true
				up_bound += 1
			end
			if !@state[x-1][up_bound].nil? && @state[x-1][up_bound].color != piece.color
				@state[x-1][up_bound] = true
			end
			while low_bound >= 0 && @state[x-1][low_bound].nil?
				possible_moves[x-1][low_bound] = true
				low_bound -= 1
			end
			if !@state[x-1][low_bound].nil? && @state[x-1][low_bound].color != piece.color
				@state[x-1][low_bound] = true
			end
			#left-right
			left_bound = x - 2
			right_bound = x
			while right_bound <= 7 && @state[right_bound][y-1].nil?
				possible_moves[right_bound][y-1] = true
				right_bound += 1
			end
			if !@state[right_bound][y-1].nil? && @state[right_bound][y-1].color != piece.color
				@state[right_bound][y-1] = true
			end
			while left_bound >= 0 && @state[left_bound][y-1].nil?
				possible_moves[left_bound][y-1] = true
				left_bound -= 1
			end
			if !@state[left_bound][y-1].nil? && @state[left_bound][y-1].color != piece.color
				@state[left_bound][y-1] = true
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
			if !@state[low_bound_x][up_bound_y].nil? && @state[low_bound_x][up_bound_y].color != piece.color
				@state[low_bound_x][up_bound_y] = true
			end
			low_bound_x = x-2
			up_bound_y = y
			while low_bound_x >= 0 && low_bound_y >= 0  && @state[low_bound_x][low_bound_y].nil?
				possible_moves[low_bound_x][low_bound_y] = true
				low_bound_x += -1
				low_bound_y += -1
			end
			if !@state[low_bound_x][low_bound_y].nil? && @state[low_bound_x][low_bound_y].color != piece.color
				@state[low_bound_x][low_bound_y] = true
			end
			low_bound_y = y-2
			while up_bound_x <= 7 && low_bound_y >= 0 && @state[up_bound_x][low_bound_y].nil?
				possible_moves[up_bound_x][low_bound_y] = true
				up_bound_x += 1
				low_bound_y += -1
			end
			if !@state[up_bound_x][low_bound_y].nil? && @state[up_bound_x][low_bound_y].color != piece.color
				@state[up_bound_x][low_bound_y] = true
			end
			up_bound_x = x
			while up_bound_x <= 7 && up_bound_y <= 7 && @state[up_bound_x][up_bound_y].nil?
				possible_moves[up_bound_x][up_bound_y] = true
				up_bound_x += 1
				up_bound_y += 1
			end
			if !@state[up_bound_x][up_bound_y].nil? && @state[up_bound_x][up_bound_y].color != piece.color
				@state[up_bound_x][up_bound_y] = true
			end
		when :knight
			for i in -2..2
				for j in -2..2
					if i.abs + j.abs == 3
						if on_board?(x-1-i,y-1-j)
							possible_moves[x-1-i][y-1-j] = true
						end
					end
				end
			end
		when :king
			for i in -1..1
				for j in -1..1
					possible_moves[x-1-i][y-1-j] = true if on_board?(x-1-i,y-1-j)
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
			if !@state[x-1][up_bound].nil? && @state[x-1][up_bound].color != piece.color
				@state[x-1][up_bound] = true
			end
			while low_bound >= 0 && @state[x-1][low_bound].nil?
				possible_moves[x-1][low_bound] = true
				low_bound -= 1
			end
			if !@state[x-1][low_bound].nil? && @state[x-1][low_bound].color != piece.color
				@state[x-1][low_bound] = true
			end
			#left-right
			left_bound = x - 2
			right_bound = x
			while right_bound <= 7 && @state[right_bound][y-1].nil?
				possible_moves[right_bound][y-1] = true
				right_bound += 1
			end
			if !@state[right_bound][y-1].nil? && @state[right_bound][y-1].color != piece.color
				@state[right_bound][y-1] = true
			end
			while left_bound >= 0 && @state[left_bound][y-1].nil?
				possible_moves[left_bound][y-1] = true
				left_bound -= 1
			end
			if !@state[left_bound][y-1].nil? && @state[left_bound][y-1].color != piece.color
				@state[left_bound][y-1] = true
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
			if !@state[low_bound_x][up_bound_y].nil? && @state[low_bound_x][up_bound_y].color != piece.color
				@state[low_bound_x][up_bound_y] = true
			end
			low_bound_x = x-2
			up_bound_y = y
			while low_bound_x >= 0 && low_bound_y >= 0  && @state[low_bound_x][low_bound_y].nil?
				possible_moves[low_bound_x][low_bound_y] = true
				low_bound_x += -1
				low_bound_y += -1
			end
			if !@state[low_bound_x][low_bound_y].nil? && @state[low_bound_x][low_bound_y].color != piece.color
				@state[low_bound_x][low_bound_y] = true
			end
			low_bound_y = y-2
			while up_bound_x <= 7 && low_bound_y >= 0 && @state[up_bound_x][low_bound_y].nil?
				possible_moves[up_bound_x][low_bound_y] = true
				up_bound_x += 1
				low_bound_y += -1
			end
			if !@state[up_bound_x][low_bound_y].nil? && @state[up_bound_x][low_bound_y].color != piece.color
				@state[up_bound_x][low_bound_y] = true
			end
			up_bound_x = x
			while up_bound_x <= 7 && up_bound_y <= 7 && @state[up_bound_x][up_bound_y].nil?
				possible_moves[up_bound_x][up_bound_y] = true
				up_bound_x += 1
				up_bound_y += 1
			end
			if !@state[up_bound_x][up_bound_y].nil? && @state[up_bound_x][up_bound_y].color != piece.color
				@state[up_bound_x][up_bound_y] = true
			end
		else
			raise ArgumentError
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
			legal = merge_legal_moves(legal,legal_move(piece))
		}
		legal
	end

	#throws an error for invalid moves
	def move_piece(c1,c2)
		begin
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
					@state[c2.x-1][c2.y-1] = @state[c1.x-1][c1.y-1]
					@state[c1.x-1][c1.y-1] = nil
				else
					raise ArgumentError, "Can't move there"
				end
			end
		rescue Exception => e
			print "Error: "
			puts e.message
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
	end

	def load_game
	end

	def main
	end
end