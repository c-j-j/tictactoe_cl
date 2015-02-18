require 'tictactoe/board'
require 'tictactoe/helpers/board_helper'
require 'command_line_human_player'

describe TicTacToe::CommandLineHumanPlayer do

  let(:board) { TicTacToe::Board.new(3) }
  let(:input) { StringIO.new }
  let(:output) { StringIO.new }
  let(:board_helper) { TicTacToe::BoardHelper.new }
  let(:player) { TicTacToe::CommandLineHumanPlayer.new('X', input, output) }

  it 'gets move from user and decrements' do
    input.string = "1\n"
    expect(player.next_move(board)).to eq(0)
  end

  it 'performs validation against board' do
    board_helper.add_moves_to_board(board, [0], 'X')
    expect(player.move_valid?(1, board)).to eq(false)
  end

  it 'non integers are invalid' do
    expect(player.move_valid?('a', board)).to eq(false)
  end

  it 'builds command line human player with factory' do
    factory = TicTacToe::CommandLineHumanPlayer::Factory.new
    player = factory.build_with_mark('X')
    expect(player.mark).to eq('X')
  end
end
