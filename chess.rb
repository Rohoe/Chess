require 'yaml'

class Coord
	attr_accessor :alpha, :int

	def initialize(x,y)
		@x = x
		@y = y
	end

end

class Player
	attr_reader :color :name

	def initialize (color, name)
		@color = color
		@name = name
	end

end

class Piece
	attr_reader :name
	attr_accessor :status, :position, :color

	def initialize(name, position, color)
		@name = name
		@status = :alive
		@position = position
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
	end

end

class Board
	attr_accessor :state, :current_player, :other_player

end

class Game
	attr_accessor :board, :players
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