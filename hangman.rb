require 'csv'

class Hangman
	def initialize
		@dictionary = File.readlines("5desk.txt")
		@game_over = false
		
		load_saves
	end

	def new_game
		@secret_word = @dictionary.select{|word| word.length > 6 && word.length < 13 }.sample.downcase.chars[0...-1]
		@letters = ("a".."z").to_a
		@incorrect_letters = []
		@correct_letters = []
		@puzzle = []
		@count = 7
		@secret_word.length.times {@puzzle += ["_"]}
		play_turn
	end

	def display_puzzle
		puts "\n"
		puts "Your Puzzle"
		puts "#{@puzzle.join}"
		puts "Correct guesses: #{@correct_letters.join(", ")}"
		puts "Incorrect guesses: #{@incorrect_letters.join(", ")}"
		puts "#{@count} incorrect guesses left."
	end

	def play_turn
		while @game_over == false
			display_puzzle
			@invalid_letter = true
			puts "What letter would you like to guess?" 
			puts "(Type 'save' to save your game.')"
			@guessed_letter = gets.chomp.downcase
			check_input
			check_puzzle if @invalid_letter == false
		end		
	end
	
	def check_input
		if @guessed_letter == "save"
			save_game
		elsif @correct_letters.include?(@guessed_letter) || @incorrect_letters.include?(@guessed_letter)
			puts "You already guessed that letter!"
		elsif @letters.include?(@guessed_letter) == false
			puts "Please enter a valid letter!"
		else 
			@invalid_letter = false
		end
	end

	def check_puzzle
		@letters -= [@guessed_letter]
		if @secret_word.include?(@guessed_letter)
			puts "Nice, '#{@guessed_letter}' is in the secret code!"
			@correct_letters += [@guessed_letter]
			add_letter_to_puzzle			
		else 
			puts "Sorry, '#{@guessed_letter}' is not in the secret code."
			@incorrect_letters += [@guessed_letter]
			@count -= 1
		end
		check_game_over
	end
			
	def add_letter_to_puzzle
		@puzzle_index = []
		@secret_word.each_with_index do |letter, index|
			@puzzle_index += [index] if letter == @guessed_letter
		end
		@puzzle_index.each {|index| @puzzle[index] = @guessed_letter}
	end

	def check_game_over
		if @puzzle == @secret_word
			display_puzzle
			puts "You saved your hangman. You win!"
			@game_over = true
		elsif @count == 0
			puts "You guessed wrong too many times. You lose!"
			puts "The secret word was '#{@secret_word.join}.'"
			@game_over = true 
		end
	end

	def load_saves
		puts "Would you like to load a game?"
		@input = gets.chomp.downcase
		if @input == "yes"
			if !(File.exist?("saved_games/saves.csv"))
				puts "There are no saved games. Starting new game"
				new_game
			else
				puts "\nSaved Games:\n"
				saves = CSV.read("saved_games/saves.csv", quote_char: "|")
  	  	saves.each_with_index do |save, index| 
  	    	puts "#{index + 1}. #{save[0]}"
				end
								puts "Choose the number of your save."
				save_chose = gets.chomp.to_i
				load_game(saves, save_chose)
				play_turn
			end	
		elsif @input == "no"
			puts "Starting new game."
			new_game
		else
			puts "Please enter 'yes' or 'no'."
			load_saves
		end
	end

	def load_game(s, sc)
		@secret_word = s[sc - 1][1].chars
		@letters = s[sc - 1][2].chars
		@incorrect_letters = s[sc - 1][3].chars
		@correct_letters = s[sc - 1][4].chars
		@puzzle = s[sc - 1][5].chars
		@count = s[sc - 1][6].to_i
		puts "#{s[sc - 1][0]} loaded."
	end

	def save_game
		@game_over = true
		Dir.mkdir('saved_games') unless Dir.exist? 'saved_games'
		puts "What would you like your save name to be?"
		@save_name = gets.chomp
		csv = File.open("saved_games/saves.csv", "a")
		csv.write("#{@save_name},#{@secret_word.join},#{@letters.join},#{@incorrect_letters.join},#{@correct_letters.join},#{@puzzle.join},#{@count}\n")
		
		csv.close
		puts "Your game has been saved!"
	end
end

n = Hangman.new
