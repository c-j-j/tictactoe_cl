require 'command_line_utils'

module TicTacToe
  class CommandLineHumanPlayer
    include CommandLineUtils

    attr_reader :input, :mark

    def initialize(mark, input=$stdin, output=$stdout)
      @mark = mark
      @input = input
      @output = output
    end

    def next_move(board)
      user_move = get_validated_user_input {|input| move_valid?(input, board)}
      transform_input_to_zero_based_integer(user_move)
    end

    def move_valid?(move, board)
      is_integer?(move) && board.is_move_valid?(transform_input_to_zero_based_integer(move))
    end

    class Factory
      def build_with_mark(mark)
        TicTacToe::CommandLineHumanPlayer.new(mark)
      end
    end
  end
end
