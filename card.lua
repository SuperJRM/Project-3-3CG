
require "vector"

CardClass = {}

CARD_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
  GRABBED = 2
}

function CardClass:new(xPos, yPos, cost, power, cardName, cardText)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card, metadata)
  
  card.position = Vector(xPos, yPos)
  card.size = Vector(50, 70)
  card.state = CARD_STATE.IDLE
  card.flipped = false
  card.revealed = false
  
  card.cost = cost
  card.power = power
  card.cardName = cardName
  card.cardText = cardText
  
  return card
end

function CardClass:update()
  --a
end

function CardClass:draw()
  -- Draws shadow if hovered over or grabbed
  if self.state ~= CARD_STATE.IDLE then
    love.graphics.setColor(0, 0, 0, 0.8) -- color values [0, 1]
    local offset = 8 * (self.state == CARD_STATE.GRABBED and 2 or 1)
    love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, 6, 6)
  end
  
  -- Draws cards designs
  if self.flipped == false then
    love.graphics.setColor(150, 0, 150, 1)
  else
    love.graphics.setColor(1, 1, 1, 1)
  end
  -- Generic card draw
  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("line", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
  
  -- Unique card draw
  if self.flipped == true then
    love.graphics.print(tostring(self.cost), self.position.x + 5, self.position.y)
    love.graphics.print(tostring(self.power), self.position.x + self.size.x - 10, self.position.y)
    love.graphics.printf(self.cardName, self.position.x + 10, self.position.y + 5, 50, "left")
    love.graphics.setFont(microFont)
    love.graphics.printf(self.cardText, self.position.x, self.position.y + (self.size.y * 1 / 3), 50, "center")
    love.graphics.setFont(font)
  end
end