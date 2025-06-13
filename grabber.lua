
require "vector"

GrabberClass = {}

-- Creates a new grabber
function GrabberClass:new()
  local grabber = {}
  local metadata = {__index = GrabberClass}
  setmetatable(grabber, metadata)
  
  grabber.currentMousePos = Vector(0,0)
  grabber.heldObject = nil
  grabber.pastObjectPos = nil
  grabber.currentLocation = nil
  grabber.pastLocation = nil
  grabber.onCooldown = false
  
  return grabber
end

function GrabberClass:update()
  -- Updates mouse position
  checkPos = Vector(
    love.mouse.getX(), 
    love.mouse.getY())
  if checkPos ~= nil then
    self.currentMousePos = checkPos
  end
  
  -- Finds location currently below grabber
  self.currentLocation = nil
  for _, loc in ipairs(gameTable) do
    locationCheck = loc:checkLocationOverlap(self.currentMousePos)
    if locationCheck ~= nil then
      self.currentLocation = locationCheck
      break
    end
  end
  
  -- Handles mouse inputs
  if love.mouse.isDown(1) then
    self:grab()
    self.onCooldown = true
  end
  if not love.mouse.isDown(1) then
    self:release()
    self.onCooldown = false
  end
end

-- Handles card grabbing
function GrabberClass:grab()
  -- Moves already grabbed cards
  if self.heldObject ~= nil then
    self.heldObject.position = self.currentMousePos - (self.heldObject.size / 2)
  
  -- Handles empty grabber
  else
    if self.currentLocation ~= nil then
      -- Grabs from overlapping hand location
      if self.currentLocation.locationType == LOCATION_TYPE.HAND and 
      self.currentLocation.playerType == PLAYER_TYPE.PLAYER and self.onCooldown == false then
        -- Checks each card if grabber is overlapping
        for i, checkCard in ipairs(self.currentLocation.cardList) do
          if isOverTarget(self.currentMousePos, checkCard) and checkCard.cost <= playerMana then
            self.pastLocation = self.currentLocation
            self.pastObjectPos = checkCard.position
            self.heldObject = table.remove(self.currentLocation.cardList, i)
            self.heldObject.state = CARD_STATE.GRABBED
            break
          end
        end
      end
      
    -- If no location is selected and grabber is empty
    else
      -- If End Turn Button is grabbed
      if (self.currentMousePos.x > WIDTH - 50 and self.currentMousePos.x < WIDTH + 100) and
      (self.currentMousePos.y > HEIGHT - 100 and self.currentMousePos.y < HEIGHT - 50) and 
      self.onCooldown == false and gameStatus == GAME_STATUS.PLAYER_TURN then
        enemyTurn(turn)
      end
      
      -- If Reset Button is grabbed
      if (self.currentMousePos.x > 0 and self.currentMousePos.x < 250) and
      (self.currentMousePos.y > 250 and self.currentMousePos.y < 325) and 
      self.onCooldown == false and gameStatus == GAME_STATUS.PLAYER_TURN then
        setUpBoard()
      end
    end
  end
end

-- Handles releasing cards
function GrabberClass:release()
  if self.heldObject ~= nil then
    -- Plays grabbed cards on overlapping board location
    if self.currentLocation ~= nil and self.currentLocation.locationType ~= LOCATION_TYPE.HAND and 
    #self.currentLocation.cardList < self.currentLocation.cardMax and self.currentLocation.playerType == PLAYER_TYPE.PLAYER then
      dropCard = self.heldObject
      self.currentLocation:addCard(dropCard)
      playerMana = playerMana - dropCard.cost
      self.heldObject = nil
      self.pastObjectPos = nil
      
    -- Returns held cards to previous location if new one is invalid
    else
      dropCard = self.heldObject
      dropCard.state = CARD_STATE.IDLE
      dropCard.position = self.pastObjectPos
      table.insert(self.pastLocation.cardList, dropCard)
      self.heldObject = nil
      self.pastObjectPos = nil
    end

  -- Changes states of cards hovered over within current location
  else
    if self.currentLocation ~= nil then
      for _, loc in ipairs(gameTable) do
        for i, card in ipairs(loc.cardList) do
          card.state = CARD_STATE.IDLE
        end
      end
      self.currentLocation:updateCards(self.currentMousePos)
    end
  end
end
