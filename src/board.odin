package main

Board :: struct {
	// only 3 lanes for turrets for now
	turrets_area:  [TURRETS_WIDTH][TURRETS_HEIGHT]TileState,
	// allow for 6 machines lanes
	machines_area: [MACHINES_WIDTH][MACHINES_HEIGHT]TileState,
}

TileType :: enum {
	Turret,
	Machine,
	Invalid,
}

TileState :: enum {
	Empty,
	Hovered,
	Busy,
}

Tile :: struct {
	type: TileType,
	col:  i32,
	row:  i32,
}

set_hover_tile :: proc(board: ^Board, tile: Tile) {
	_clear_hovers(board)
	switch tile.type {
	case .Machine:
		board.machines_area[tile.col][tile.row] = .Hovered
	case .Turret:
		board.turrets_area[tile.col][tile.row] = .Hovered
	case .Invalid:
	}
}

_clear_hovers :: proc(board: ^Board) {
	for i in 0 ..< TURRETS_WIDTH {
		for j in 0 ..< TURRETS_HEIGHT {
			if board.turrets_area[i][j] == .Hovered {
				board.turrets_area[i][j] = .Empty
			}
		}
	}
	for i in 0 ..< MACHINES_WIDTH {
		for j in 0 ..< MACHINES_HEIGHT {
			if board.machines_area[i][j] == .Hovered {
				board.machines_area[i][j] = .Empty
			}
		}
	}
}

_get_tile :: proc(game: ^Game, x: i32, y: i32) -> Tile {
	result := Tile {
		type = .Invalid,
	}

	// check if it is a turrent tile or a machine tile
	if f32(x) > game.ratio * TILE_SIZE && f32(x) < WINDOW_WIDTH - game.ratio * TILE_SIZE {
		if f32(y) >= _to_screen_size(game, UI_HEIGHT) &&
		   f32(y) < _to_screen_size(game, UI_HEIGHT + TURRETS_HEIGHT) {
			result.type = .Turret
			result.col = x / i32(game.ratio * TILE_SIZE) - (UI_WIDTH)
			result.row = y / i32(game.ratio * TILE_SIZE) - (UI_HEIGHT)
		} else if f32(y) >= _to_screen_size(game, 5) &&
		   f32(y) < _to_screen_size(game, GRID_HEIGHT - 1) {
			result.type = .Machine
			result.col = x / i32(game.ratio * TILE_SIZE) - (UI_WIDTH)
			result.row = y / i32(game.ratio * TILE_SIZE) - (UI_HEIGHT + TURRETS_HEIGHT + UI_GAP)
		}
	}

	return result
}

_to_screen_size :: proc(game: ^Game, n: i32) -> f32 {
	return f32(n) * game.ratio * f32(TILE_SIZE)
}
