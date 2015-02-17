require 'tictactoe'
require 'command_line_interface.rb'

require 'ostruct'

describe TTT::CommandLineInterface do

  let(:board) { TTT::Board.new(3) }
  let(:board_helper) { TTT::BoardHelper.new }
  let(:stub_game) {TTT::StubGame.new }
  let(:input) { StringIO.new }
  let(:output) { StringIO.new }
  let(:user_interface) { TTT::CommandLineInterface.new(input, output) }
  let(:game_presenter) { TTT::GamePresenter::Builder.new
    .with_board(board).with_current_player_is_computer(true).build }

  it 'prints empty board with numbers' do
    user_interface.print_board(board)
    rows = output.string.lines

    expect(rows[0]).to include("1  2  3")
    expect(rows[1]).to include("4  5  6")
    expect(rows[2]).to include("7  8  9")
  end

  it 'grabs the next move and decrements by 1' do
    input.string = '1'
    expect(user_interface.get_user_move(board)).to eq(0)
  end

  it 'performs validation against non-integer inputted' do
    user_input('A', '1')
    user_interface.get_user_move(board)
    expect(output.string).to include(TTT::CommandLineInterface::INVALID_MOVE_MESSAGE)
  end

  it 'performs validation against board' do
    board_helper.add_moves_to_board(board, [0], 'X')
    user_input('1', '2')
    user_interface.get_user_move(board)
    expect(output.string).to include(TTT::CommandLineInterface::INVALID_MOVE_MESSAGE)
  end

  it 'prints invalid message' do
    user_interface.print_invalid_message
    expect(output.string).to include(TTT::CommandLineInterface::INVALID_MOVE_MESSAGE)
  end

  it 'user_interfaces prompt to pick game type' do
    user_input('1')
    game_type_description = 'SomeGameDescription'
    user_interface.get_game_type({
      :GameType => game_type_description
    })
    expect(output.string).to include(TTT::CommandLineInterface::PICK_GAME_TYPE)
    expect(output.string).to include(game_type_description)
  end

  it 'user inputs integer to specify game type' do
    game_choices = [
      'Human Vs Human'
    ]
    user_input('1')
    expect(user_interface.get_game_type(game_choices)).to eq('Human Vs Human')
  end

  it 'validates user input with choices provided' do
    game_choices = [
      'Human Vs Human'
    ]

    user_input('a', '0', '1')
    user_interface.get_game_type(game_choices)
    expect(output.string).to include(TTT::CommandLineInterface::INVALID_MOVE_MESSAGE)
  end

  it 'prompts user to specify board size' do
    user_input('3')
    user_interface.get_board_size(3)
    expect(output.string).to include(TTT::CommandLineInterface::PICK_BOARD_SIZE)
    expect(output.string).to include('3')
  end

  it 'gets user input for board size' do
    user_input('3')
    expect(user_interface.get_board_size(3)).to eq(3)
  end

  it 'invalidates user input for board size if non-integer provided' do
    user_input('a', '3')
    expect(user_interface.get_board_size(3, 4)).to eq(3)
    expect(output.string).to include(TTT::CommandLineInterface::INVALID_MOVE_MESSAGE)
  end

  it 'invalidates user input if board size provided not in list of options' do
    user_input('5', '4')
    expect(user_interface.get_board_size(3, 4)).to eq(4)
    expect(output.string).to include(TTT::CommandLineInterface::INVALID_MOVE_MESSAGE)
  end

  it 'requests board size when prepare_game is called' do
    user_input('1', '3')
    user_interface.prepare_game
    expect(output.string).to include(TTT::CommandLineInterface::PICK_BOARD_SIZE)
  end

  it 'user_interfaces board sizes retrieved from game object' do
    user_input('1', '3')
    user_interface.prepare_game
    TTT::Game::BOARD_SIZES.each do |size|
      expect(output.string).to include(size.to_s)
    end
  end

  it 'requests game type when prepare_game is called' do
    user_input('1', '3')
    user_interface.prepare_game
    expect(output.string).to include(TTT::CommandLineInterface::PICK_GAME_TYPE)
  end

  it 'user_interfaces game types retreived from game object' do
    user_input('1', '3')
    user_interface.prepare_game
    TTT::Game::GAME_TYPES.each do |type|
      expect(output.string).to include(type)
    end
  end

  it 'builds game from input' do
    user_input('1','3')
    user_interface.prepare_game
    expect(user_interface.game).to be_kind_of(TTT::Game)
  end

  it 'plays turn on game when computer is going next' do
    stub_game.play_turn_ends_game
    game_presenter.current_player_is_computer = true
    stub_game.set_presenter(game_presenter)
    user_interface.play_game(stub_game)
    expect(stub_game.play_turn_called?).to be(true)
  end

  it 'gets next turn from user when human is going next' do
    stub_game.play_turn_ends_game
    game_presenter.current_player_is_computer = false
    stub_game.set_presenter(game_presenter)
    user_input('1')
    user_interface.play_game(stub_game)
    expect(stub_game.play_turn_called?).to be(true)
  end

  it 'prints board to screen when move has been made' do
    p1_mark = 'X'
    p2_mark = 'O'
    generate_board_with_moves(p1_mark, p2_mark)
    stub_game.play_turn_ends_game
    stub_game.set_presenter(game_presenter)
    user_interface.play_game(stub_game)

    assert_board_is_correct(p1_mark, p2_mark)
  end

  it 'prints board when game is over' do
    p1_mark = 'X'
    p2_mark = 'O'
    generate_board_with_moves(p1_mark, p2_mark)

    game_presenter.state = TTT::Game::DRAW
    stub_game.register_game_over
    stub_game.set_presenter(game_presenter)
    user_interface.play_game(stub_game)
    assert_board_is_correct(p1_mark, p2_mark)
  end

  it 'user_interfaces winner' do
    stub_game.register_game_over
    game_presenter.state = TTT::Game::WON
    game_presenter.winner = 'X'
    stub_game.set_presenter(game_presenter)
    user_interface.play_game(stub_game)
    expect(output.string).to include("X has won.")
  end

  def generate_board_with_moves(p1_mark, p2_mark)
    board_helper.add_moves_to_board(board, [0, 1, 2, 6, 7, 8], p1_mark)
    board_helper.add_moves_to_board(board, [3, 4, 5], p2_mark)
  end

  def user_input(*inputs)
    input_string = ''
    inputs.each do |element|
      input_string << element << "\n"
    end
    input.string = input_string
  end

  def assert_board_is_correct(p1_mark, p2_mark)
    rows = output.string.lines
    expect(rows[0]).to include("#{p1_mark}  #{p1_mark}  #{p1_mark} ")
    expect(rows[1]).to include("#{p2_mark}  #{p2_mark}  #{p2_mark} ")
    expect(rows[2]).to include("#{p1_mark}  #{p1_mark}  #{p1_mark} ")
    return rows
  end
end
