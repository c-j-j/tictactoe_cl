require 'tictactoe'

module TTT
  class CommandLineInterface

    attr_reader :game
    PICK_GAME_TYPE = "Pick Game Type?\n"
    PICK_BOARD_SIZE = "Pick Board Size? Options are:\n"
    INVALID_MOVE_MESSAGE = "Invalid move. Try again."

    def initialize(input=$stdin, output=$stdout, game=nil)
      @input = input
      @output = output
      @game = game
    end

    def show
      prepare_game if @game.nil?
      play_game(@game)
    end

    def play_game(game)
      until game.game_over?
        print_update(game.presenter)
        if game.presenter.computer_has_next_turn?
          game.play_turn
        else
          game.play_turn(get_user_move(game.presenter.board))
        end
      end

      print_update(game.presenter)
    end

    def get_user_move(board)
      user_move = get_validated_user_input {|input| move_valid?(input, board)}
      transform_input_to_zero_based_integer(user_move)
    end

    def prepare_game
      game_type = get_game_type(Game::GAME_TYPES)
      board_size = get_board_size(*Game::BOARD_SIZES)
      @game = TTT::Game.build_game(self, game_type, board_size)
    end


    def print_board(board)
      output = ""
      index = 1

      board.rows.each_with_index do |row|
        row.each do |mark|
          unless mark.nil?
            print_mark(output, mark)
          else
            print_mark(output, index)
          end
          index += 1 #unable to break this down to due counter
        end
        output << "\n"
      end
      @output.puts output
    end

    def print_invalid_message
      @output.puts INVALID_MOVE_MESSAGE
    end

    def get_board_size(*board_size_options)
      @output.puts PICK_BOARD_SIZE
      print_board_size_options(board_size_options)
      board_size = get_validated_user_input {|input| board_size_valid?(input, board_size_options)}
      board_size.to_i
    end

    def get_game_type(game_choices)
      @output.puts PICK_GAME_TYPE
      print_game_choices(game_choices)
      game_type = get_validated_user_input {|input| game_type_valid?(input, game_choices)}
      game_choices[transform_input_to_zero_based_integer(game_type)]
    end

    private

    def print_update(game_presenter)
      print_board(game_presenter.board)
      print_status(game_presenter.status)
    end

    def print_status(status)
      @output.puts status
    end

    def get_validated_user_input(&validation)
      while true
        input = get_user_input
        break if validation.call(input) unless validation.nil?
        print_invalid_message
      end
      input
    end

    def board_size_valid?(board_size, board_size_options)
      is_integer?(board_size) && board_size_options.include?(board_size.to_i)
    end

    def print_game_choices(game_choices)
      game_choices.each_with_index do |game_choice, index|
        @output.puts "#{index + 1}: #{game_choice}\n"
      end
    end

    def print_board_size_options(board_size_options)
      board_size_options.each do |option|
        @output.puts "#{option}, "
      end
    end

    def print_mark(output, mark)
      output << " #{mark} "
    end

    def game_type_valid?(game_type, game_choices)
      is_integer?(game_type) && (1..game_choices.size) === game_type.to_i
    end

    def transform_input_to_zero_based_integer(move)
      move.to_i - 1
    end

    def get_user_input
      @input.gets.chomp
    end

    def move_valid?(move, board)
      is_integer?(move) && board.is_move_valid?(transform_input_to_zero_based_integer(move))
    end

    def is_integer?(string)
      string.to_i.to_s == string
    end
  end
end
