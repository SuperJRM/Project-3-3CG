
require "vector"

GrabberClass = {}

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
  -- Update mouse pos
  checkPos = Vector(
    love.mouse.getX(), 
    love.mouse.getY())
  if checkPos ~= nil then
    self.currentMousePos = checkPos
  end
  
  -- Find location currently below grabber
  self.currentLocation = nil
  for _, loc in ipairs(gameTable) do
    locationCheck = loc:checkLocationOverlap(self.currentMousePos)
    if locationCheck ~= nil then
      self.currentLocation = locationCheck
      break
    end
  end
  
  -- Mouse inputs
  if love.mouse.isDown(1) then
    self:grab()
    self.onCooldown = true
  end
  if not love.mouse.isDown(1) then
    self:release()
    self.onCooldown = false
  end
end

-- On mouse click
function GrabberClass:grab()
  -- Moves already grabbed cards
  if self.heldObject ~= nil then
    self.heldObject.position = self.currentMousePos - (self.heldObject.size / 2)
  
  -- Mouse is over a location
  else
    if self.currentLocation ~= nil then
      -- Grab from hand
      if self.currentLocation.locationType == LOCATION_TYPE.HAND and 
      self.currentLocation.playerType == PLAYER_TYPE.PLAYER and self.onCooldown == false then
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
      
    -- If no location is selected, buttons
    else
      -- End Turn Button
      if (self.currentMousePos.x > WIDTH - 50 and self.currentMousePos.x < WIDTH + 100) and
      (self.currentMousePos.y > HEIGHT - 100 and self.currentMousePos.y < HEIGHT - 50) and 
      self.onCooldown == false and gameStatus == GAME_STATUS.PLAYER_TURN then
        enemyTurn(turn)
      end
      
      -- Reset Button
      if (self.currentMousePos.x > 0 and self.currentMousePos.x < 250) and
      (self.currentMousePos.y > 250 and self.currentMousePos.y < 325) and 
      self.onCooldown == false and gameStatus == GAME_STATUS.PLAYER_TURN then
        setUpBoard()
      end
    end
  end
end

-- On mouse release
function GrabberClass:release()
  if self.heldObject ~= nil then
    -- Places gabbed cards into board location
    if self.currentLocation ~= nil and self.currentLocation.locationType ~= LOCATION_TYPE.HAND and 
    #self.currentLocation.cardList < self.currentLocation.cardMax and self.currentLocation.playerType == PLAYER_TYPE.PLAYER then
      dropCard = self.heldObject
      self.currentLocation:addCard(dropCard)
      playerMana = playerMana - dropCard.cost
      self.heldObject = nil
      self.pastObjectPos = nil
      
    -- Returns held cards to previous position if new one is invalid
    else
      dropCard = self.heldObject
      dropCard.state = CARD_STATE.IDLE
      dropCard.position = self.pastObjectPos
      table.insert(self.pastLocation.cardList, dropCard)
      self.heldObject = nil
      self.pastObjectPos = nil
    end

  -- Changes card states within current location
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
