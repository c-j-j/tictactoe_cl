module TicTacToe
  module CommandLineUtils

    INVALID_MOVE_MESSAGE = "Invalid input. Please try again"

    def output
      raise "output method not implemented"
    end

    def input
      raise "input method not implemented"
    end

    def get_user_input
      input.gets.chomp
    end

    def transform_input_to_zero_based_integer(move)
      move.to_i - 1
    end

    def is_integer?(string)
      string.to_i.to_s == string
    end

    def get_validated_user_input(&validation)
      while true
        input = get_user_input
        break if validation.call(input) unless validation.nil?
        print_invalid_message
      end
      input
    end

    def print_invalid_message
      output.puts INVALID_MOVE_MESSAGE
    end
  end
end

