package main
import "core:fmt"
import rl "vendor:raylib"

GameState :: enum {
	MainMenu,
	Running,
	GameOver,
}


Game :: struct {
	board:  Board,
	energy: f32,
	ratio:  f32,
	state:  GameState,
}

init_game :: proc(game: ^Game) {
	currentMonitor := rl.GetCurrentMonitor()
	game.state = .MainMenu
	width_ratio := f32(WINDOW_WIDTH) / (TILE_SIZE * f32(GRID_WIDTH))
	height_ration := f32(WINDOW_HEIGHT) / (TILE_SIZE * f32(GRID_HEIGHT))
	game.ratio = width_ratio < height_ration ? width_ratio : height_ration


}

update_game :: proc(game: ^Game, dt: f32) {

	switch game.state {
	case .MainMenu:
		_update_main_menu(game, dt)
	case .Running:
		mouse_x := rl.GetMouseX()
		mouse_y := rl.GetMouseY()
		tile := _get_tile(game, mouse_x, mouse_y)
		set_hover_tile(&game.board, tile)

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
		_draw_running(game)
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

_draw_running :: proc(game: ^Game) {
	energy_str := fmt.ctprintf("Energy: %f", game.energy)
	rl.DrawText(energy_str, 100, 100, 16, rl.WHITE)

	for i in 0 ..< TURRETS_WIDTH {
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
	}
}

_draw_game_over :: proc(game: ^Game) {
}
