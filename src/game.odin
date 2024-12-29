package main
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

GameState :: enum {
	MainMenu,
	Running,
	GameOver,
}

Level :: struct {
	col:   int,
	row:   int,
	tiles: [][]Tile,
}


Game :: struct {
	//board:         Board,
	energy:        f32,
	ratio:         f32,
	state:         GameState,
	level:         Level,
	tilemap:       rl.Texture2D,
	current_level: int,
}

load_levels :: proc(filename: string, game: ^Game) {
	// clean up before loading the levels again
	for row in game.level.tiles {
		delete(row)
	}
	delete(game.level.tiles)

	data, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.eprintln("Error openning levels! %s", filename)
		return
	}
	defer delete(data)

	text := string(data)
	lines := strings.split_lines(text)
	defer delete(lines)

	i := 0
	for i < len(lines) {
		splits := strings.split(lines[i], string(" "))
		i += 1
		defer delete(splits)

		// there's a new level
		if len(splits) >= 2 {
			ncol := strconv.atoi(splits[0])
			nrow := strconv.atoi(splits[1])
			if ncol != 0 && nrow != 0 {
				game.level.col = ncol
				game.level.row = nrow
				game.level.tiles = make([][]Tile, nrow)

				for line, idx in lines[i:i + nrow] {
					game.level.tiles[idx] = make([]Tile, ncol)
					for letter, cidx in line {
						newTile := Tile {
							row = i32(idx),
							col = i32(cidx),
							t   = letter,
						}
						game.level.tiles[idx][cidx] = newTile
					}
				}

				i += nrow
			} else {
				continue
			}
		}

	}
}

init_game :: proc(game: ^Game) {
	currentMonitor := rl.GetCurrentMonitor()
	game.state = .MainMenu
	width_ratio := f32(WINDOW_WIDTH) / (TILE_SIZE * f32(GRID_WIDTH))
	height_ration := f32(WINDOW_HEIGHT) / (TILE_SIZE * f32(GRID_HEIGHT))
	game.ratio = width_ratio < height_ration ? width_ratio : height_ration


	game.tilemap = rl.LoadTexture("assets/tilemap.png")
	game.current_level = 0
}

unload_game :: proc(game: ^Game) {
	for row in game.level.tiles {
		delete(row)
	}
	delete(game.level.tiles)
	rl.UnloadTexture(game.tilemap)
}

update_game :: proc(game: ^Game, dt: f32) {

	switch game.state {
	case .MainMenu:
		_update_main_menu(game, dt)
	case .Running:
		mouse_x := rl.GetMouseX()
		mouse_y := rl.GetMouseY()
		tile := _get_tile(game, mouse_x, mouse_y)

	case .GameOver:
	case:
	// default
	}
}

draw_game :: proc(game: ^Game) {
	switch game.state {
	case .MainMenu:
		_draw_main_menu(game)
	case .Running:
		_draw_tiles(game)
		_draw_running(game)
		_draw_cursor(game)
		_draw_ui(game)
	case .GameOver:
		_draw_game_over(game)
	case:
	// default
	}

}

_update_main_menu :: proc(game: ^Game, dt: f32) {

	if rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
		game.state = .Running
	}

}

_draw_main_menu :: proc(game: ^Game) {

	rl.DrawText("Area 53", 300, 300, 24, rl.BLACK)
	rl.DrawText("Press ENTER to begin", 300, 330, 16, rl.WHITE)
	rl.DrawText("Press ESC to close the game", 300, 360, 16, rl.WHITE)
}

_draw_tiles :: proc(game: ^Game) {
	for row, i in game.level.tiles {
		for col, j in row {
			switch col.t {
			case 't':
				_draw_tile_at(game, 1, 1, i32(j), i32(i))
			case 'g':
				_draw_tile_at(game, 1, 2, i32(j), i32(i))
			case 'm':
				_draw_tile_at(game, 1, 3, i32(j), i32(i))
			case 's':
				_draw_tile_at(game, 1, 4, i32(j), i32(i))
			case 'x':
				_draw_tile_at(game, 1, 5, i32(j), i32(i))
			case ',':
				_draw_tile_at(game, 2, 3, i32(j), i32(i))
			case 'c':
				_draw_tile_at(game, 3, 3, i32(j), i32(i))
			case 'a':
				_draw_tile_at(game, 4, 0, i32(j), i32(i))
			case 'q':
				_draw_tile_at(game, 4, 1, i32(j), i32(i))
			case 'd':
				_draw_tile_at(game, 6, 0, i32(j), i32(i))
			case 'e':
				_draw_tile_at(game, 6, 1, i32(j), i32(i))
			case 'w':
				_draw_tile_at(game, 5, 0, i32(j), i32(i))
			case 'p':
				_draw_tile_at(game, 5, 1, i32(j), i32(i))
			case '1':
				_draw_tile_at(game, 1, 0, i32(j), i32(i))
			case '2':
				_draw_tile_at(game, 2, 0, i32(j), i32(i))
			case '3':
				_draw_tile_at(game, 3, 0, i32(j), i32(i))
			case '4':
				_draw_tile_at(game, 5, 2, i32(j), i32(i))
			case '5':
				_draw_tile_at(game, 5, 3, i32(j), i32(i))
			case '6':
				_draw_tile_at(game, 5, 4, i32(j), i32(i))
			case:
				_draw_tile_at(game, 0, 5, i32(j), i32(i))
			}
		}
	}
}

_draw_running :: proc(game: ^Game) {

	/*for i in 0 ..< TURRETS_WIDTH {
		for j in 0 ..< TURRETS_HEIGHT {
			color := rl.BLUE
			switch game.board.turrets_area[i][j] {
			case .Hovered:
				color = rl.YELLOW
			case .Busy, .Empty:
			}
			rl.DrawRectangle(
				i32(f32(i + 1) * game.ratio * TILE_SIZE),
				i32(f32(j + 1) * game.ratio * TILE_SIZE),
				i32(f32(TILE_SIZE) * game.ratio),
				i32(f32(TILE_SIZE) * game.ratio),
				color,
			)
		}
	}

	for i in 0 ..< MACHINES_WIDTH {
		for j in 0 ..< MACHINES_HEIGHT {
			color := rl.BLUE
			switch game.board.machines_area[i][j] {
			case .Hovered:
				color = rl.YELLOW
			case .Busy, .Empty:
			}
			rl.DrawRectangle(
				i32(f32(i + 1) * game.ratio * TILE_SIZE),
				i32(f32(j + 5) * game.ratio * TILE_SIZE),
				i32(f32(TILE_SIZE) * game.ratio),
				i32(f32(TILE_SIZE) * game.ratio),
				color,
			)
		}
	}*/
}

_draw_tile_at :: proc(game: ^Game, tile_x, tile_y, pos_x, pos_y: i32, color: rl.Color = rl.WHITE) {
	rl.DrawTexturePro(
		game.tilemap,
		{f32(tile_x * TILE_SIZE), f32(tile_y * TILE_SIZE), TILE_SIZE, TILE_SIZE},
		{
			_to_screen_size(game, pos_x),
			_to_screen_size(game, pos_y),
			_to_screen_size(game, 1),
			_to_screen_size(game, 1),
		},
		{0, 0},
		0,
		color,
	)
}

_draw_cursor :: proc(game: ^Game) {
	tilex := _to_game_size(game, rl.GetMouseX())
	tiley := _to_game_size(game, rl.GetMouseY())

	_draw_tile_at(game, 0, 7, tilex, tiley)
}

_draw_ui :: proc(game: ^Game) {
	energy_str := fmt.ctprintf("Energy: %f", game.energy)

	energy_x := _to_screen_size(game, 1)
	rl.DrawText(
		energy_str,
		i32(f32(TILE_SIZE) * game.ratio),
		i32(f32(TILE_SIZE) * game.ratio / 2),
		16,
		rl.WHITE,
	)

	// draw lightning
	rl.DrawTexturePro(
		game.tilemap,
		{f32(1 * TILE_SIZE), f32(8 * TILE_SIZE), TILE_SIZE, TILE_SIZE},
		{
			TILE_SIZE * game.ratio / 4,
			TILE_SIZE * game.ratio / 4,
			TILE_SIZE * game.ratio / 2,
			TILE_SIZE * game.ratio / 2,
		},
		{0, 0},
		0,
		rl.WHITE,
	)
	//_draw_tile_at(game, 1, 8, 0, 0)
}

_draw_game_over :: proc(game: ^Game) {
}
