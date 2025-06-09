
require "vector"

LocationClass = {}

LOCATION_TYPE = {
  HAND = 0,
  BOARD_LEFT = 1,
  BOARD_CENTER = 2,
  BOARD_RIGHT = 3
}

PLAYER_TYPE = {
  PLAYER = 0,
  ENEMY = 1
}

CARD_SLOTS = {
  Vector(0,0),
  Vector(1,0),
  Vector(0,1),
  Vector(1,1)
}

listoCards = {}

function LocationClass:new(xPos, yPos, xSize, ySize)
  local location = {}
  local metadata = {__index = LocationClass}
  setmetatable(location, metadata)
  
  location.position = Vector(xPos, yPos)
  location.size = Vector(xSize, ySize)
  location.cardList = {}
  location.cardMax =  4
  location.locationType = LOCATION_TYPE.HAND
  location.playerType = PLAYER_TYPE.PLAYER
  
  return location
end

function LocationClass:update()
end

function LocationClass:draw()
  if self.locationType == LOCATION_TYPE.HAND then
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", self.position.x, self.position.y, self.size.x, self.size.y)
  else
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", self.position.x, self.position.y, self.size.x, self.size.y)
  end
  
  for _, locCard in ipairs(self.cardList) do
    locCard:draw()
  end
end

-- Returns location below location, for grabber
function LocationClass:checkLocationOverlap(currentPos)
  if isOverTarget(currentPos, self) == true then
    return self
  else
    return nil
  end
end

function LocationClass:addCard(cardAdded)
  cardAdded.state = CARD_STATE.IDLE
  offset = cardAdded.size * CARD_SLOTS[#self.cardList + 1]
  cardAdded.position = self.position + offset
  table.insert(self.cardList, cardAdded)
end

function LocationClass:updateCards(currentPos)
  -- Changes card states
  if #self.cardList > 0 then
    for i = 1, #self.cardList do
      if self.cardList[i].flipped == true and isOverTarget(currentPos, self.cardList[i]) then
        self.cardList[i].state = CARD_STATE.MOUSE_OVER
      else
        self.cardList[i].state = CARD_STATE.IDLE
      end
    end
  end
end
