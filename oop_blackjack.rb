# oop_blackjack.rb

# Rules & Requirements:
# Blackjack is a card game where you calculate the sum of the values of your cards and try to hit 21, aka "blackjack".
# Both the player and dealer are dealt two cards to start the game. All face cards are worth whatever numerical value they show.
# Suit cards are worth 10. Aces can be worth either 11 or 1. Example: if you have a Jack and an Ace, then you have hit "blackjack", as it adds up to 21.

# After being dealt the initial 2 cards, the player goes first and can choose to either "hit" or "stay".
# Hitting means deal another card. If the player's cards sum up to be greater than 21, the player has "busted" and lost.
# If the sum is 21, then the player wins. If the sum is less than 21, then the player can choose to "hit" or "stay" again.
# If the player "hits", then repeat above, but if the player stays, then the player's total value is saved, and the turn moves to the dealer.

# By rule, the dealer must hit until she has at least 17. If the dealer busts, then the player wins.
# If the dealer, hits 21, then the dealer wins.
# If, however, the dealer stays, then we compare the sums of the two hands between the player and dealer; higher value wins.





require 'pry'

class Deck
  NUMBER_OF_DECKS = 1

  attr_reader :cards

  def initialize
    @cards = []
    iteration = 0
    until iteration == NUMBER_OF_DECKS
      iteration += 1
      Card::SUITS.each do |suit|
        Card::FACE_VALUE.each do |value|
          cards << Card.new(suit,value)
        end
      end
    end
    cards.shuffle!
  end

  def draw_card
    cards.pop
  end


end

class Card
  SUITS = ['H','D','C','S']
  FACE_VALUE = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
  attr_reader :suit, :face_value

  def initialize(suit, face_value)
    @suit = suit
    @face_value = face_value
  end

end

module Hand
  CARD_VALUES = {'2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9, '10' => 10, 'J' => 10, 'Q' => 10, 'K' => 10, 'A' =>11}
  BLACKJACK = 21

  attr_accessor :hand, :hold_card, :score

  def add_card(card)
    hand << card
  end

  def add_hold_card(card)
    hold_card << card
  end

  def calculate_hand_score
    score = 0
    hand.each do |card|
        score += CARD_VALUES[card.face_value]
    end

    hand.each do |card|
      score -= 10 if score > 21 && card.face_value == 'A'
    end
    score
  end

  def blackjack?
    calculate_hand_score == BLACKJACK && hand.size == 2
  end

  def busted?
    calculate_hand_score > BLACKJACK
  end

  def show_hand
    puts "----- #{name}'s Hand -----"
    hand.each do |card|
      puts "=> #{card.suit} #{card.face_value}"
    end
    puts "=> Score: #{calculate_hand_score}"
  end

  def clear_hand
    hand.clear
  end

end

class Player
  include Hand
  attr_reader :name

  def initialize(name)
    @name = name
    @hand = []
  end

end

class Dealer
  include Hand

  MIN_HAND_SCORE = 17

  attr_reader :name

  def initialize(name)
    @name = name
    @hand = []
    @hold_card = []
  end

  def flop_card
    hand.concat(hold_card)
  end

end

class Game

  attr_accessor :player, :dealer, :deck

  def initialize
    @player = Player.new(ask_player_name)
    @dealer = Dealer.new('Dealer')
    @deck = Deck.new
  end

  def ask_player_name
    puts "Welcome to blackjack"
    puts "Please enter your name!"
    gets.chomp
  end

  def deal_cards
    player.add_card(@deck.draw_card)
    dealer.add_card(@deck.draw_card)
    player.add_card(@deck.draw_card)
    dealer.add_hold_card(@deck.draw_card)
  end

  def show_hand
    player.show_hand
    dealer.show_hand
  end

  def hit_or_stay?

    while @player.calculate_hand_score <= Hand::BLACKJACK && !@player.busted?
      puts "#{player.name}: Do you want to (H) - Hit or (S) - Stay?"

      player_action = gets.chomp.downcase

      loop do
        break if %w(h s).include?(player_action)
        puts "Please choose: H for Hit, S for Stay"
        player_action = gets.chomp.downcase
      end

      break if player_action == 's'

      player.add_card(@deck.draw_card)
      show_hand

    end

  end

  def player_got_blackjack?
    player.blackjack?
  end

  def player_busted?
    player.busted?
  end

  def dealer_busted?
    dealer.busted?
  end

  def player_turn
    if player_got_blackjack?
      puts "Player has blackjack!"
    else
      hit_or_stay?
    end
  end

  def flop_dealer_card
    puts "Showing dealer's card"
    dealer.flop_card
    dealer.show_hand
  end

  def announce_winner
    if dealer.calculate_hand_score <= Hand::BLACKJACK && (player_busted? || dealer.calculate_hand_score > player.calculate_hand_score)
      puts "#{dealer.name} wins!"
    elsif player.calculate_hand_score <= Hand::BLACKJACK && (dealer_busted? || player.calculate_hand_score > dealer.calculate_hand_score)
      puts "#{player.name} Wins!"
    else
      puts "It's a tie"
    end
  end

  def clear_hands
    player.clear_hand
    dealer.clear_hand
  end


  def dealer_turn
    until dealer.calculate_hand_score >= Dealer::MIN_HAND_SCORE || dealer_busted?
      puts "Dealer adds another card!"
      dealer.add_card(deck.draw_card)
      dealer.show_hand
    end

  end

  def finish_game?
    puts "Play again? 1) Yes, 2) No"
    gets.chomp == '2'
  end

  def play
    loop do
      deal_cards
      show_hand
      player_turn
      flop_dealer_card
      if player_got_blackjack?
        announce_winner
      else
        dealer_turn
        announce_winner
      end
      break if finish_game?
      clear_hands
    end

    puts "Goodbye"
  end


end

Game.new.play


