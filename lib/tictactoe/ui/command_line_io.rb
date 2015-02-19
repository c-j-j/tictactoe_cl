module TicTacToe
  module UI
    module CommandLineIO

      INVALID_INPUT_MESSAGE = "Invalid input. Please try again"

      def output
        raise "output method not implemented"
      end

      def input
        raise "input method not implemented"
      end

      def get_user_input
        input.gets.chomp
      end

      def print_message(message)
        output.puts message
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
        output.puts INVALID_INPUT_MESSAGE
      end
    end
  end
end
