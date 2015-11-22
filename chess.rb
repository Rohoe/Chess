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
	attr_reader :name
	attr_accessor :status, :color, :position

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

	#returns array of 1s and 0s corresponding to legal/illegal moves
	def legal_move(piece)
		possible_moves = empty_state
		case piece.name
		when :pawn
			if piece.color == :white
				x = piece.position.x
				y = piece.position.y
			else #black
			end
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
			print "* "
		end
	end

	def merge_legal_moves
	end

	def legal_moves(player)
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