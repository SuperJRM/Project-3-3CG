-- Jason Rangle-Martinez
-- CMPM 121 - 3CG Project - Mythical Mash-Up
-- 5/28/25
io.stdout:setvbuf("no")

require "card"
require "vector"
require "grabber"
require "location"

WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

GAME_STATUS = {
  PLAYER_TURN = "Player 1 Turn",
  ENEMY_TURN = "Player 2 Turn",
  DECIDING = "Coin Flip:",
  WINNER = "Winner"
}

function love.load()
  love.window.setMode(960,640)
  love.graphics.setBackgroundColor(0.3, 0.3, 0.8, 1)
  love.window.setTitle("Mythical Mash-Up")
  
  font = love.graphics.newFont(8)
  medFont = love.graphics.newFont(16)
  bigFont = love.graphics.newFont(32)
  biggestFont = love.graphics.newFont(64)
  microFont = love.graphics.newFont(7)
  love.graphics.setFont(font)
  grabber = GrabberClass:new()
  
  setUpBoard()
end

function love.draw()
  love.graphics.setFont(font)
  for _, loc in ipairs(gameTable) do
    loc:draw()
  end
  
  if #playerDeck > 0 then
    playerDeck[#playerDeck]:draw()
    enemyDeck[#enemyDeck]:draw()
  end
  
  if grabber.heldObject ~= nil then
    grabber.heldObject:draw()
  end
  
  love.graphics.setFont(medFont)
  love.graphics.print("Deck:", 50, 75)
  love.graphics.print("Deck:", 50, HEIGHT - 25)
  love.graphics.print("Discard:", WIDTH - 50, 75)
  love.graphics.print("Discard:", WIDTH - 50, HEIGHT - 25)
    
  
  love.graphics.setFont(bigFont)
  for loc = 1, 3 do
    love.graphics.print(tostring(eScores[loc]), 175 + (200 * (loc - 1)), 200)
    love.graphics.print(tostring(eScores[loc]), 175 + (200 * (loc - 1)), 375)
  end
  love.graphics.print("Total: " .. tostring(pScoreTotal), 775, 200)
  love.graphics.print("Total: " .. tostring(eScoreTotal), 775, 375)
  
  love.graphics.print("Mana: " .. tostring(enemyMana), 25, 125)
  love.graphics.print("Mana: " .. tostring(playerMana), 25, HEIGHT - 100)
  love.graphics.print("End Turn", WIDTH - 50, HEIGHT - 100)
  
  if pWinCheck == true then
    love.graphics.setFont(biggestFont)
    if eWinCheck == true then
      if tieFlip == 1 then
        love.graphics.print("Tie? Player 1 Wins", 250, 250)
      else
        love.graphics.print("Tie? Player 2 Wins", 250, 250)
      end
      love.graphics.print("Reset", 0, 250)
    else
      love.graphics.print("Player 2 Wins", 250, 250)
      love.graphics.print("Reset", 0, 250)
    end
  elseif eWinCheck == true then
    love.graphics.setFont(biggestFont)
    love.graphics.print("Player 1 Wins", 250, 250)
    love.graphics.print("Reset", 0, 250)
  else
  end
end

function love.update()
  grabber:update()
end

function isOverTarget(origin, target)
  return (origin.x > target.position.x and 
  origin.x < (target.position.x + target.size.x) and
  origin.y > target.position.y and 
  origin.y < target.position.y + target.size.y)
end

function setUpBoard()
  gameTable = {}
  gameStatus = GAME_STATUS.PLAYER_TURN
  playerDeck = {}
  enemyDeck = {}
  turn = 1
  maxPlayerMana = 1
  maxEnemyMana = 1
  playerMana = maxPlayerMana
  enemyMana = maxEnemyMana
  pScores = {0, 0, 0}
  pScoreTotal = 0
  eScores = {0, 0, 0}
  eScoreTotal = 0
  pWinCheck = false
  eWinCheck = false
  tieFlip = love.math.random(1, 2)
  
  fillDeck(playerDeck, 100, HEIGHT - 50)
  fillDeck(enemyDeck, 100, 50)
  players = {PLAYER_TYPE.ENEMY, PLAYER_TYPE.PLAYER}
  for side = 1, 2 do
    --sidePosition = Vector(200, (HEIGHT * (side - 1)) - (100 * (side - 2)))
    if side == 1 then
      sidePosition = Vector(200, 50)
    else
      sidePosition = Vector(200, HEIGHT - 50)
    end
    playerType = players[side]
    
    -- Hand
    hand = newLocation(sidePosition.x, sidePosition.y - (50 * (side - 1)), 500, 75)
    hand.locationType = LOCATION_TYPE.HAND
    hand.playerType = playerType
    hand.cardMax = 8
    table.insert(gameTable, hand)
    
    -- Board
    for loc = 1, 3 do
      boardLoc = newLocation(sidePosition.x + (sidePosition.x * (loc - 1)), sidePosition.y + 100 - (325 * (side - 1)), 120, 150)
      boardLoc.locationType = LOCATION_TYPE[loc + 1]
      boardLoc.playerType = playerType
      table.insert(gameTable, boardLoc)
    end
  end
  startTurn(turn)
end

function startTurn(turnCount)
  if turnCount == 1 then
    for i = 1, 3 do
      drawCard(enemyDeck, gameTable[1])
      drawCard(playerDeck, gameTable[5])
    end
  else
    drawCard(enemyDeck, gameTable[1])
    drawCard(playerDeck, gameTable[5])
  end
  
  playerMana = maxPlayerMana
  enemyMana = maxEnemyMana
end

function enemyTurn(turnCount)
  selectedCards = {}
  enemyHand = gameTable[1].cardList
  for i = #enemyHand, 1, -1 do
    heldCard = enemyHand[i]
    if heldCard.cost <= enemyMana then
      randLocs = {2, 3, 4}
      while #randLocs > 0 do
        randSelect = table.remove(randLocs, love.math.random(1, #randLocs))
        selectedLocation = gameTable[randSelect]
        if #selectedLocation.cardList < selectedLocation.cardMax then
          table.remove(enemyHand, i)
          selectedLocation:addCard(heldCard)
          enemyMana = enemyMana - heldCard.cost
          break
        end
      end
    end
  end
  endTurn(turnCount)
end

function endTurn(turnCount)
  pScores = {0, 0, 0}
  eScores = {0, 0, 0}
  for i = 1, 3 do
    for _, scoreCards in ipairs(gameTable[1 + i].cardList) do
      pScores[i] = pScores[i] + scoreCards.power
    end
    for _, scoreCards in ipairs(gameTable[5 + i].cardList) do
      eScores[i] = eScores[i] + scoreCards.power
    end
    tempScore = eScores[i] - pScores[i]
    if tempScore <= 0 then
      pScoreTotal = pScoreTotal + (tempScore * -1)
    else
      eScoreTotal = eScoreTotal + tempScore
    end
  end
  
  -- If player wins
  if pScoreTotal >= 30 then
    pWinCheck = true
  end
  -- If opponent wins
  if eScoreTotal >= 30 then
    eWinCheck = true
  end
  -- Game continues to next round
  if pScoreTotal < 30 and eScoreTotal < 30 then
    maxPlayerMana = maxPlayerMana + 1
    maxEnemyMana = maxEnemyMana + 1
    startTurn(turnCount + 1)
  end
end
  

function fillDeck(deck, xPos, yPos)
  table.insert(deck, CardClass:new(xPos, yPos, 6, 4, "Nyx", "When Revealed: Discards your other cards here, add their power to this card."))
  table.insert(deck, CardClass:new(xPos, yPos, 6, 12, "Titan", "Big Guy"))
  table.insert(deck, CardClass:new(xPos, yPos, 5, 6, "Hades", "When Revealed: Gain +2 power for each card in your discard pile."))
  table.insert(deck, CardClass:new(xPos, yPos, 5, 9, "Minotaur", "Man Bull"))
  table.insert(deck, CardClass:new(xPos, yPos, 4, 3, "Aphrodite", "When Revealed: Lower the power of each enemy card here by 1."))
  table.insert(deck, CardClass:new(xPos, yPos, 3, 3, "Dionysus", "When Revealed: Gain +2 power for each of your other cards here."))
  table.insert(deck, CardClass:new(xPos, yPos, 3, 6, "Medusa", "When ANY other card is played here, lower that card's power by 1."))
  table.insert(deck, CardClass:new(xPos, yPos, 3, 1, "Ares", "When Revealed: Gain +2 power for each enemy card here."))
  table.insert(deck, CardClass:new(xPos, yPos, 3, 5, "Pegasus", "Flying Horse"))
  table.insert(deck, CardClass:new(xPos, yPos, 2, 5, "Atlas", "End of Turn: Loses 1 power if your side of this location is full."))
  for i = 1, 2 do
    table.insert(deck, CardClass:new(xPos, yPos, 2, 3, "Daedalus", "When Revealed: Add a Wooden Cow to each other location."))
    table.insert(deck, CardClass:new(xPos, yPos, 2, 1, "Ship of Theseus", "When Revealed: Add a copy with +1 power to your hand."))
    table.insert(deck, CardClass:new(xPos, yPos, 2, 2, "Cyclops", "When Revealed: Discard your other cards here, gain +2 power for each discarded."))
    table.insert(deck, CardClass:new(xPos, yPos, 1, 2, "Artemis", "When Revealed: Gain +5 power if there is exactly one enemy card here."))
    table.insert(deck, CardClass:new(xPos, yPos, 1, 1, "Wooden Cow", "THE COW"))
  end
end

function drawCard(deck, hand)
  if #deck > 0 and #hand.cardList <= 7 then
    cardPull = table.remove(deck, love.math.random(1, #deck))
    cardPull.flipped = true
    if #hand.cardList < 1 then
      cardPull.position = Vector(hand.position.x + 5, hand.position.y)
    else
      lastCard = hand.cardList[#hand.cardList]
      cardPull.position = Vector(lastCard.position.x + 50, lastCard.position.y)
    end
    table.insert(hand.cardList, cardPull)
  end
end

function newLocation(x, y, xSize, ySize)
  local newLocation = LocationClass:new(x, y, xSize, ySize)
  return newLocation
end

