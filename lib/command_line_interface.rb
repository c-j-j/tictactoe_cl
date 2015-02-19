require 'tictactoe/game'
require 'command_line_human_player'
require 'command_line_io'

module TicTacToe
  class CommandLineInterface
    include CommandLineIO

    attr_reader :game, :input, :output
    PICK_GAME_TYPE = "Pick Game Type?"
    PICK_BOARD_SIZE = "Pick Board Size? Options are:"

    def initialize(input=$stdin, output=$stdout, game=nil)
      @input = input
      @output = output
      @game = game
    end

    def show
      game = @game || prepare_game
      play_game(game)
    end

    def prepare_game
      game_type = get_game_type(Game::GAME_TYPES)
      board_size = get_board_size(*Game::BOARD_SIZES)
      TicTacToe::Game.build_game(game_type, board_size, TicTacToe::CommandLineHumanPlayer::Factory.new)
    end

    def play_game(game)
      until game.game_over?
        print_update(game.presenter)
        game.play_turn
      end

      print_update(game.presenter)
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
      print_message(output)
    end

    def get_board_size(*board_size_options)
      print_message(PICK_BOARD_SIZE)
      print_board_size_options(board_size_options)
      board_size = get_validated_user_input {|input| board_size_valid?(input, board_size_options)}
      board_size.to_i
    end

    def get_game_type(game_choices)
      print_message(PICK_GAME_TYPE)
      print_game_choices(game_choices)
      game_type = get_validated_user_input {|input| game_type_valid?(input, game_choices)}
      game_choices[transform_input_to_zero_based_integer(game_type)]
    end

    private

    def print_update(game_presenter)
      print_board(game_presenter.board)
      print_message(game_presenter.status)
    end

    def board_size_valid?(board_size, board_size_options)
      is_integer?(board_size) && board_size_options.include?(board_size.to_i)
    end

    def print_game_choices(game_choices)
      game_choices.each_with_index do |game_choice, index|
        print_message("#{index + 1}: #{game_choice}")
      end
    end

    def print_board_size_options(board_size_options)
      board_size_options.each do |option|
        print_message("#{option}, ")
      end
    end

    def print_mark(output, mark)
      output << " #{mark} "
    end

    def transform_input_to_zero_based_integer(move)
      move.to_i - 1
    end

    def is_integer?(string)
      string.to_i.to_s == string
    end

    def game_type_valid?(game_type, game_choices)
      is_integer?(game_type) && (1..game_choices.size) === game_type.to_i
    end
  end
end
