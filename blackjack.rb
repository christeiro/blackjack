require 'pry'


NUMBER_OF_DECKS = 5
SUITS = ['H','D','C','S']
CARDS = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
CARD_VALUES = {'2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9, '10' => 10, 'J' => 10, 'Q' => 10, 'K' => 10, 'A' =>11}
BLACKJACK = 21
DEALER_MIN = 16

def shuffle_cards
  prepare_cards = []
  iteration = 0
  begin 
    iteration += 1
    SUITS.each do |suit|
      CARDS.each do |card|
        prepare_cards << [suit,card]
      end
    end
  end until iteration == NUMBER_OF_DECKS
  prepare_cards.shuffle!
end

def calculate_score(cards)
  cards_score = 0
  cards.each do |card|
    cards_score += CARD_VALUES[card[1]]
  end

  cards.each do |card|
    cards_score -= 10 if cards_score > 21 && card.include?('A')
  end
  cards_score
end


def check_winner(player_cards, dealer_cards)
  player_sum = calculate_score(player_cards)
  dealer_sum = calculate_score(dealer_cards)
  if player_sum <= BLACKJACK && (dealer_sum < player_sum || dealer_sum > BLACKJACK)
    'Player'
  elsif dealer_sum <= BLACKJACK && (player_sum < dealer_sum || player_sum > BLACKJACK)
    'Dealer'
  else
    'Tie'
  end
end

def draw_game_board(player_hand,dealer_hand)
  # system "clear"
  puts "Dealer cards: #{dealer_hand}. SCORE: #{calculate_score(dealer_hand)}"
  puts "#{PLAYER_NAME} cards #{player_hand}. SCORE: #{calculate_score(player_hand)}"
  puts ""
end

def announce_winner(player_score, dealer_score)
  if dealer_score <= BLACKJACK && (dealer_score > player_score || player_score > BLACKJACK)
    puts "Dealer Wins"
  elsif player_score <= BLACKJACK && (player_score > dealer_score || dealer_score > BLACKJACK)
    puts "#{PLAYER_NAME} Wins!"
  else
    puts "It's a tie"
  end
end

# Shuffle cards and start the game
game_cards = shuffle_cards

puts "Welcome to blackjack"

puts "Please enter your name!"

PLAYER_NAME = gets.chomp

puts ""

begin 

  # Variables for the game
  player_cards = []
  dealer_cards = []
  hold_card = []
  player_score = 0
  dealer_score = 0
  game_over = false
  player_busted = false
  exit_game = nil


  player_cards << game_cards.pop
  dealer_cards << game_cards.pop
  player_cards << game_cards.pop
  # Hold card - later added to dealers card
  hold_card << game_cards.pop

  draw_game_board(player_cards,dealer_cards)

  player_score = calculate_score(player_cards)


  # Player gets a blackjack with first two cards. Check if dealer also has Blackjack
  if player_score == BLACKJACK 
    puts "#{PLAYER_NAME} got Blackjack. Showing dealer cards"
    dealer_cards.concat(hold_card)
    dealer_score = calculate_score(dealer_cards)
    draw_game_board(player_cards,dealer_cards)
    announce_winner(player_score,dealer_score)
    game_over = true
  end
  
  unless game_over

    while player_score <= BLACKJACK && !player_busted
      puts "#{PLAYER_NAME}: Do you want to (H) - Hit or (S) - Stay?"
      player_action = gets.chomp.downcase

      loop do
        break if %w(h s).include?(player_action)
        puts "Please choose: H for Hit, S for Stay"
        player_action = gets.chomp.downcase
      end
      
      break if player_action == 's'
      
      player_cards << game_cards.pop
      draw_game_board(player_cards,dealer_cards)
      player_score = calculate_score(player_cards)
      # 
      player_busted = true if player_score > BLACKJACK

    end

    # Add "hold card" to dealer cards
    
    puts "Showing dealer cards!"
    dealer_cards.concat(hold_card)
    draw_game_board(player_cards,dealer_cards)
    dealer_score = calculate_score(dealer_cards)
    if dealer_score == BLACKJACK || player_busted
      puts "Dealer wins!"
      game_over = true
    end
  
    # Dealer draws until gets at least 17
    while dealer_score <= DEALER_MIN && !game_over
      puts "Dealer draws additional card!"
      dealer_cards << game_cards.pop
      draw_game_board(player_cards,dealer_cards)
      dealer_score = calculate_score(dealer_cards)
    end

  end

  announce_winner(player_score, dealer_score) if !game_over

  loop do 
    puts "Do you want to play again? Y - yes, N - no"
    exit_game = gets.chomp.downcase
    break if ['y','n'].include?(exit_game)
  end

  system "clear" if exit_game == 'y'

end until exit_game == 'n'

puts "Goodbye!"
