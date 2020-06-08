Level = Class{}

function Level:init()
	self.world = love.physics.newWorld(0, 300)

	self.destroyedBodies = {}

	function beginContact(a, b, call)
		local types = {}
		types[a:getUserData()] = true
		types[b:getUserData()] = true

		if types['Obstacle'] and types['Player'] then
			local playerFixture = a:getUserData() == 'Player' and a or b
			local obstacleFixture = a:getUserData() == 'Obstacle' and a or b

			local velX, velY = playerFixture:getBody():getLinearVelocity()
			local sumVel = math.abs(velX) + math.abs(velY)

			if sumVel > 20 then
				table.insert(self.destroyedBodies, obstacleFixture:getBody())
			end
		end

		if types['Obstacle'] and types['Alien'] then
			local obstacleFixture = a:getUserData() == 'Obstacle' and a or b
			local alienFixture = a:getUserData() == 'Alien' and a or b

			local velX, velY = obstacleFixture:getBody():getLinearVelocity()
			local sumVel = math.abs(velX) + math.abs(velX)

			if sumVel > 20 then
				table.insert(self.destroyedBodies, alienFixture:getBody())
			end
		end

		if types['Player'] and types['Alien'] then
			local playerFixture = a:getUserData() == 'Player' and a or b
			local alienFixture = a:getUserData() == 'Alien' and a or b
			
			local velX, velY = plyerFixture:getBody():getLinearVelocity()
			local sumVel = math.abs(velX) + math.abs(velY)

			if sumVel > 20 then
				table.insert(self.destroyedBodies, alienFixture:getBody())
			end
		end

		if types['Player'] and types['Ground'] then
			gSounds['bounce']:stop()
			gSounds['bounce']:play()
		end
	end

	function endContact(a, b, coll)
		
	end

	function preSolve(a, b, coll)

	end

	function postSolve(a, b, coll, normalImpulse, tangentImpulse)

	end

	self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	self.launchMarker = AlienLaunchMarker(self.world)

	self.aliens = {}
	table.insert(self.aliens, Alien(self.world, 'square', VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - TILE_SIZE - ALIEN_SIZE / 2, 'Alien'))

	self.obstacles = {}
	table.insert(self.obstacles, Obstacle(self.world, 'vertical',
		VIRTUAL_WIDTH - 120, VIRTUAL_HEIGHT - 35 - 110 / 2))
	table.insert(self.obstacles, Obstacle(self.world, 'vertical',
		VIRTUAL_WIDTH - 35, VIRTUAL_HEIGHT - 35 - 110 / 2))
	table.insert(self.obstacles, Obstacle(self.world, 'horizontal',
		VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - 35 - 110 - 35 / 2))

	self.edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH * 3, 0)
	self.groundBody = love.physics.newBody(self.world, -VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 35, 'static')
	self.groundFixture = love.physics.newFixture(self.groundBody, self.edgeShape)
	self.groundFixture:setFriction(0.5)
	self.groundFixture:setUserData('Ground')

	self.background = Background()
end

function Level:update(dt)
	self.launchMarker:update(dt)

	self.world:update(dt)

	for k, body in pairs(self.destroyedBodies) do
		if not body:isDestroyed() then
			body:destroy()
		end
	end

	self.destroyedBodies = {}

	for i = #self.obstacles, 1, -1 do
		if self.obstacles[i].body:isDestroyed() then
			table.remove(self.obstacles, i)

			local soundNum = math.random(5)
			gSounds['break' .. tostring(soundNum)]:stop()
			gSounds['break' .. tostring(soundNum)]:play()
		end
	end

	for i = #self.aliens, 1, -1 do
		if self.aliens[i].body:isDestroyed() then
			table.remove(self.aliens, i)
			gSounds['kill']:stop()
			gSounds['kill']:play()
		end
	end

	if self.launchMarker.launched then
		local xPos, yPos = self.launchMarker.alien.body:getPosition()
		local xVel, yVel = self.launchMarker.alien.body:getLinearVelocity()
		
		if xPos < 0 or (math.abs(xVel) + math.abs(yVel) < 1.5) then
			self.launchMarker.alien.body:destroy()
			self.launchMarker = AlienLaunchMarker(self.world)

			if #self.aliens == 0 then
				gStateMachine:change('start')
			end
		end
	end
	
end

function Level:render()
	for x = -VIRTUAL_WIDTH, VIRTUAL_WIDTH * 2, 35 do
		love.graphics.draw(gTextures['tiles'], gFrames['tiles'][12], x, VIRTUAL_HEIGHT - 35)
	end

	self.launchMarker:render()

	for k, alien in pairs(self.aliens) do
		alien:render()
	end

	for k, obstacle in pairs(self.obstacles) do
		obstacle:render()
	end

	if not self.launchMarker.launched then
		love.graphics.setFont(gFonts['medium'])
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf('Click and drag circular alien to shoot!', 0, 64, VIRTUAL_WIDTH, 'center')
		love.graphics.setColor(1, 1, 1, 1)
	end

	if #self.aliens == 0 then
		love.graphics.setFont(gFonts['huge'])
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf('VICTORY', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')
		love.graphics.setColor(1, 1, 1, 1)
	end
end
