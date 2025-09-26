print("starting maze generation")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wallTemplate = ReplicatedStorage:WaitForChild("SmallWall")

local WALL_LENGTH = 10
local WALL_HEIGHT = 15
local WALL_THICKNESS = 1

local WIDTH = 15
local HEIGHT = 20
local SEED = 67

math.randomseed(SEED)

-- grid to track visited cells
local visited = {}
for x = 1, WIDTH do
	visited[x] = {}
	for y = 1, HEIGHT do
		visited[x][y] = false
	end
end

-- tables to store walls 
local verticalWalls = {}
local horizontalWalls = {}

-- directions: right, left, up, down
local dirs = {
	{1, 0}, {-1, 0}, {0, 1}, {0, -1}
}

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

-- remove wall between two cells
local function removeWall(x1, y1, x2, y2)
	if x1 == x2 then
		-- vertical movement
		if y2 > y1 then
			-- up movement
			local wall = horizontalWalls[x1][y2]
			if wall then wall:Destroy() end
		else
			-- down movement
			local wall = horizontalWalls[x1][y1]
			if wall then wall:Destroy() end
		end
	else if y1 == y2 then
			-- horizontal movement
			if x2 > x1 then
				-- right movement
				local wall = verticalWalls[x2][y1]
				if wall then wall:Destroy() end
			else
				-- left movement
				local wall = verticalWalls[x1][y1]
				if wall then wall:Destroy() end
			end
		end
	end
end

-- depth first search to carve paths
local function carve(x, y)
	visited[x][y] = true
	local order = {1,2,3,4}
	shuffle(order)

	for _, i in ipairs(order) do
		local dx, dy = dirs[i][1], dirs[i][2]
		local nx, ny = x + dx, y + dy
		if nx > 0 and nx <= WIDTH and ny > 0 and ny <= HEIGHT and not visited[nx][ny] then
			removeWall(x, y, nx, ny)
			carve(nx, ny)
		end
	end
end

-- build the maze
local function buildMaze()
	local model = Instance.new("Model")
	model.Name = "Maze"

	-- place vertical walls
	for x = 1, WIDTH+1 do
		verticalWalls[x] = {}
		for y = 1, HEIGHT do
			local wall = wallTemplate:Clone()
			wall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, WALL_LENGTH+1)
			wall.Position = Vector3.new(x * WALL_LENGTH - WALL_LENGTH/2, WALL_HEIGHT/2, y * WALL_LENGTH)
			wall.Anchored = true
			wall.Parent = model
			verticalWalls[x][y] = wall
			print("placed wall")
		end
	end

	-- place horizontal walls
	for x = 1, WIDTH do
		horizontalWalls[x] = {}
		for y = 1, HEIGHT+1 do
			local wall = wallTemplate:Clone()
			wall.Size = Vector3.new(WALL_LENGTH+1, WALL_HEIGHT, WALL_THICKNESS)
			wall.Position = Vector3.new(x * WALL_LENGTH, WALL_HEIGHT/2, y * WALL_LENGTH - WALL_LENGTH/2)
			wall.Anchored = true
			wall.Parent = model
			horizontalWalls[x][y] = wall
			print("placed wall")
		end
	end

	-- carve paths
	carve(1,1)

	model.Parent = workspace
	print("maze generated")
end

buildMaze()