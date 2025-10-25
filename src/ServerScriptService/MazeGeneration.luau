local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wallTemplate = ReplicatedStorage:WaitForChild("SmallWall")

local WALL_LENGTH = 8
local WALL_HEIGHT = 15
local WALL_THICKNESS = 1

local WIDTH = 15
local HEIGHT = 15

local redParts = {}
local walls = {} -- hashmap to track placed walls

-- Models
local cellsModel = Instance.new("Model")
cellsModel.Name = "Cells"

local wallsModel = Instance.new("Model")
wallsModel.Name = "Walls"

-- function to add a wall only if it doesn't already exist
local function addWall(position, size)
	local key = position.X..","..position.Y..","..position.Z
	if not walls[key] then
		local wall = wallTemplate:Clone()
		wall.Size = size
		wall.Position = position
		wall.Anchored = true
		wall.Parent = wallsModel
		walls[key] = wall -- store wall for later reference
	end
end

-- build the grid
for x = 1, WIDTH do
	redParts[x] = {}
	for y = 1, HEIGHT do
		-- create the cells
		local redPart = Instance.new("Part")
		redPart.Size = Vector3.new(WALL_LENGTH - 1, 2, WALL_LENGTH - 1)
		redPart.Position = Vector3.new(x * WALL_LENGTH - WALL_LENGTH/2, 1, y * WALL_LENGTH - WALL_LENGTH/2)
		redPart.Color = Color3.fromRGB(255, 0, 0)
		redPart.Anchored = true
		redPart.Parent = cellsModel
		redParts[x][y] = redPart

		local cx, cy, cz = redPart.Position.X, redPart.Position.Y, redPart.Position.Z

		--place walls around the cell
		addWall(Vector3.new(cx, WALL_HEIGHT/2, cz - WALL_LENGTH/2), Vector3.new(WALL_THICKNESS, WALL_HEIGHT, WALL_LENGTH + 1)) -- Top
		addWall(Vector3.new(cx, WALL_HEIGHT/2, cz + WALL_LENGTH/2), Vector3.new(WALL_THICKNESS, WALL_HEIGHT, WALL_LENGTH + 1)) -- Bottom
		addWall(Vector3.new(cx - WALL_LENGTH/2, WALL_HEIGHT/2, cz), Vector3.new(WALL_LENGTH + 1, WALL_HEIGHT, WALL_THICKNESS)) -- Left
		addWall(Vector3.new(cx + WALL_LENGTH/2, WALL_HEIGHT/2, cz), Vector3.new(WALL_LENGTH + 1, WALL_HEIGHT, WALL_THICKNESS)) -- Right
	end
end

cellsModel.Parent = workspace
wallsModel.Parent = workspace
print("Cells and walls built")

-- DFS Maze generation
local visited = {}

-- remove wall between two cells
local function removeWallBetween(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1

	local cell1 = redParts[x1][y1]
	local cx, cy, cz = cell1.Position.X, cell1.Position.Y, cell1.Position.Z

	if dx == 1 then
		-- neighbor is right
		local pos = Vector3.new(cx + WALL_LENGTH/2, WALL_HEIGHT/2, cz)
		if walls[pos.X..","..pos.Y..","..pos.Z] then
			walls[pos.X..","..pos.Y..","..pos.Z]:Destroy()
			walls[pos.X..","..pos.Y..","..pos.Z] = nil
		end
	elseif dx == -1 then
		-- neighbor is left
		local pos = Vector3.new(cx - WALL_LENGTH/2, WALL_HEIGHT/2, cz)
		if walls[pos.X..","..pos.Y..","..pos.Z] then
			walls[pos.X..","..pos.Y..","..pos.Z]:Destroy()
			walls[pos.X..","..pos.Y..","..pos.Z] = nil
		end
	elseif dy == 1 then
		-- neighbor is below
		local pos = Vector3.new(cx, WALL_HEIGHT/2, cz + WALL_LENGTH/2)
		if walls[pos.X..","..pos.Y..","..pos.Z] then
			walls[pos.X..","..pos.Y..","..pos.Z]:Destroy()
			walls[pos.X..","..pos.Y..","..pos.Z] = nil
		end
	elseif dy == -1 then
		-- neighbor is above
		local pos = Vector3.new(cx, WALL_HEIGHT/2, cz - WALL_LENGTH/2)
		if walls[pos.X..","..pos.Y..","..pos.Z] then
			walls[pos.X..","..pos.Y..","..pos.Z]:Destroy()
			walls[pos.X..","..pos.Y..","..pos.Z] = nil
		end
	end
end

local function DFS(x, y)
	visited[x] = visited[x] or {}
	visited[x][y] = true

	-- shuffle directions
	local directions = {{1,0},{-1,0},{0,1},{0,-1}}
	for i = #directions, 2, -1 do
		local j = math.random(i)
		directions[i], directions[j] = directions[j], directions[i]
	end

	for _, dir in ipairs(directions) do
		local nx, ny = x + dir[1], y + dir[2]
		if nx >= 1 and nx <= WIDTH and ny >= 1 and ny <= HEIGHT then
			visited[nx] = visited[nx] or {}
			if not visited[nx][ny] then
				removeWallBetween(x, y, nx, ny)
				DFS(nx, ny)
			end
		end
	end
end

local function removeCells()
	if workspace:FindFirstChild("Cells") then
		workspace.Cells:Destroy()
		print("All cells removed")
	end
end

-- place DNA models in random cells
local function placeDNA(count)
	local dnaTemplate = ReplicatedStorage:WaitForChild("DNA")
	local pickupsModel = Instance.new("Model")
	pickupsModel.Name = "Pickups"
	pickupsModel.Parent = workspace

	local usedCells = {} -- track cells already used
	
	local cellsModel = workspace:FindFirstChild("Cells")
	if not cellsModel then
		return -- cells model doesn’t exist
	end

	if count > #cellsModel:GetChildren() then
		print("Tried placing more DNA sequences than cells in maze")
		return -- don’t place more DNA than there are cells
	end
	
	while #pickupsModel:GetChildren() < count do
		local rx = math.random(1, WIDTH)
		local ry = math.random(1, HEIGHT)

		if not usedCells[rx] then usedCells[rx] = {} end
		if not usedCells[rx][ry] then
			local cell = redParts[rx][ry]
			if cell then
				local dna = dnaTemplate:Clone()
				dna:SetPrimaryPartCFrame(CFrame.new(cell.Position + Vector3.new(0, 2, 0)))
				dna.Parent = pickupsModel
				usedCells[rx][ry] = true
			end
		end
	end
end

-- start DFS from top left
DFS(1,1)

print("Maze generation complete")
placeDNA(5)
removeCells() 
