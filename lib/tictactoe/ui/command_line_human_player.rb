require 'tictactoe/ui/command_line_io'

module TicTacToe
  module UI
    class CommandLineHumanPlayer
      include CommandLineIO

      attr_reader :input, :output, :mark

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

      def transform_input_to_zero_based_integer(move)
        move.to_i - 1
      end

      def is_integer?(string)
        string.to_i.to_s == string
      end

      class Factory
        def build_with_mark(mark)
          TicTacToe::UI::CommandLineHumanPlayer.new(mark)
        end
      end
    end
  end
end
