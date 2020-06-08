PlayState = Class{__includes = BaseState}

function PlayState:init()
	self.level = Level()
	self.levelTranslateX = 0
end

function PlayState:update(dt)
	if love.keyboard.wasPressed('escape') then
		love.event.quit()
	end

	if love.keyboard.isDown('left') then
		self.levelTranslateX = self.levelTranslateX + MAP_SCROLL_X_SPEED * dt

		if self.levelTranslateX > VIRTUAL_WIDTH then
			self.levelTranslateX = VIRTUAL_WIDTH
		else
			self.level.background:update(dt)
		end
	elseif love.keyboard.isDown('right') then
		self.levelTranslateX = self.levelTranslateX - MAP_SCROLL_X_SPEED * dt

		if self.levelTranslateX < -VIRTUAL_WIDTH then
			self.levelTranslateX = -VIRTUAL_WIDTH
		else
			self.level.background:update(dt)
		end
	end

	self.level:update(dt)
end

function PlayState:render()
	self.level.background:render()

	love.graphics.translate(math.floor(self.levelTranslateX), 0)
	self.level:render()
end