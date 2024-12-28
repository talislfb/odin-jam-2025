package main

import "core:fmt"
import "core:math"
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

Level :: struct {
	col:   int,
	row:   int,
	tiles: []string,
}

main :: proc() {

	rl.SetTargetFPS(60)
	currentMonitor := rl.GetCurrentMonitor()
	rl.InitWindow(
		WINDOW_WIDTH, //rl.GetMonitorWidth(currentMonitor),
		//rl.GetMonitorHeight(currentMonitor),
		WINDOW_HEIGHT,
		"Area 53",
	)

	data, ok := os.read_entire_file_from_filename("assets/levels.txt")
	if !ok {
		fmt.eprintln("Error openning levels!")
		return
	}
	defer delete(data)

	fmt.printfln("Failing to convert (das): %v", strconv.atoi("das"))

	l: Level

	text := string(data)
	fmt.printfln(text)
	lines := strings.split_lines(text)
	defer delete(lines)
	i := 0
	for i < len(lines) {
		splits := strings.split(lines[i], string(" "))
		i += 1
		defer delete(splits)

		// there's a new level
		if len(splits) == 2 {
			col := strconv.atoi(splits[0])
			row := strconv.atoi(splits[1])
			if col != 0 && row != 0 {
				l.col = col
				l.row = row
				l.tiles = lines[i:i + l.row]
				i += l.row
			} else {
				continue
			}
		}

	}
	fmt.print(l)

	game := new(Game)
	defer free(game)

	init_game(game)
	for !rl.WindowShouldClose() {
		update_game(game, 0.0)

		rl.BeginDrawing()
		rl.ClearBackground({100, 150, 150, 255})

		draw_game(game)
		rl.EndDrawing()
	}
}
