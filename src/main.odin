package main

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

// by default this is 5 * 160 (where 160 is to allow 10 tiles of 16)
WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 800

GRID_WIDTH :: 10
GRID_HEIGHT :: 10
TILE_SIZE :: 16
CANVAS_WIDTH :: GRID_WIDTH * TILE_SIZE
CANVAS_HEIGHT :: GRID_HEIGHT * TILE_SIZE

UI_WIDTH :: 1
UI_HEIGHT :: 1
UI_GAP :: 1
TURRETS_WIDTH :: 8
TURRETS_HEIGHT :: 3
MACHINES_WIDTH :: 8
MACHINES_HEIGHT :: 4

main :: proc() {

	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	rl.SetTargetFPS(60)
	currentMonitor := rl.GetCurrentMonitor()
	rl.InitWindow(
		WINDOW_WIDTH, //rl.GetMonitorWidth(currentMonitor),
		//rl.GetMonitorHeight(currentMonitor),
		WINDOW_HEIGHT,
		"Area 53",
	)


	game := new(Game)
	defer {
		unload_game(game)
		free(game)
	}

	load_levels("assets/levels.txt", game)
	init_game(game)
	for !rl.WindowShouldClose() {
		update_game(game, rl.GetFrameTime())

		rl.BeginDrawing()
		rl.ClearBackground({0, 0, 0, 255})

		draw_game(game)
		rl.EndDrawing()
	}
}
