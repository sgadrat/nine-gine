Nine-gine
*********

Introduction
============

Nine-gine is a game engine for the Nintendo Entertainment System (NES). It provides the needed system routines and utility functions to let the developers focus on games mechanics. Nine-gine is developed in assembly language and structured to easily build NROM games, the assembler directly outputs a valid iNES file.

**Features:**

* Main loop and interrupts handled by the engine
* Easy game structuring based on state-machine
* Layered animations for natural horizontal-flip
* Playing music loops
* Collision handling
* Input handling
* Running seamlessly on PAL and NTSC systems
* Various utility functions

Base concepts and structure
===========================

Game's states
-------------

A game is a collection of states. At any time, the game is on one of these states and can transition to another one. For example, a simple game could have two states: the title screen and the gameplay scene. The game would start on the title screen, transition and to gameplay when the player presses start.

A state has two routines, an initialization routine called once when entering the state, and a tick routine called each frame. It allows separating concerns and avoid pollution of the main states' code with logic handling menus, title screens and other supporting states.

Memory registers
----------------

The last 16 bytes of the zero page are used throughout the engine as memory registers. It can be used to store routines parameters, results or intermediate values. Labels *tmpfield1* to *tmpfield16* represent these addresses. Engine routines indicate which of these fields are used or impacted in a comment.

Tools
=====

Nametable buffers
-----------------

The background can only be modified during the NMI, and the NMI interruption is entirely handled by Nine-gine itself. Nametable buffers allow the game to modify background between frames by storing modifications in memory to be processed by the NMI handler.

Nametable buffers are stored sequentially beginning at the label *nametable_buffers* and using the following format:

+-----------------------+------------------------+----------------------+----------------------+
| byte 0 "continuation" | byte 1,2 "PPU address" | byte 3 "tiles count" | byte 4,5,... "tiles" |
+=======================+========================+======================+======================+
| 0 or 1                | MSB, LSB (big endian)  | Number of tiles      | one tile per byte    |
+-----------------------+------------------------+----------------------+----------------------+

* *continuation*: always 1, put a 0 after the last buffer to mark the end of the list
* *PPU address*: address of the first byte to modify (PPU memory)
* *tiles count*: number of bytes in this buffer
* *tiles*: bytes to write in PPU memory

Note: while Nametable buffers are notably useful to modify nametables, hence the name, it can be effectively used to write anywhere in PPU memory.

Animations
----------

Nine-gine allows defining multi-layers animations. It means that each 8x8 sprite composing the meta-sprite has its own Z-Index which is used by the engine to flip sprites naturally. So if your character holds his weapon in the right hand, flipping the sprite keeps it on the right hand.

An animation is defined by data about meta-sprites forming the animation, then it can be drawn on screen by the *animation_draw* routine


Music
-----

TODO

Step by step game creation
==========================

Goal
----

You will create a very little game, moving a sprite on a background. This will show the very basics of the game engine and give you something to improve upon.

A basic understanding of the NES' internals can be of great help to understand what you will be doing, but is not necessary to complete follow the steps.

Setup your environment
----------------------

You will need the XA cross assembler for 6502. It may be found on Archlinux in the package "community/xa", on Ubuntu in the package "xa65" and, for other platforms, you may find information `here <http://www.floodgap.com/retrotech/xa/>`_.

Clone the nine-gine repository::

	$ git clone <github_repository>

The top-level directory contains the following files and sub directory:

* *nine.asm*: buildable file, it contains links to other files and instructions to build the project
* *nine/*: engine directory, contains nine-gine's source files, you should not have to modify it
* *game/*: game directory, contains game-specific source files, you will write things here
* *game-sample/*: a little game to learn from

As you just got a fresh repository from git, the *game/* directory is a symbolic link to the *game-sample/* directory. You can test that everything is fine by building the sample game::

	$ xa nine.asm -C -o game.nes

If everything is fine, it creates the *game.nes* file which is a valid ROM that you can run in your emulator of choice.

Remove the symlink named *game/* and create a new directory with this name. It will contain the sources of your game.

Write mandatory files
---------------------

There is four mandatory files for any game

* *game/game_states.asm*: definition of game states and associated routines
* *game/music/music.asm*: musics data
* *game/animations/animations.asm*: animations data
* *game/chr_rom.asm*: CHR-ROM contents

Create these files now, you will learn to use each of them in following paragraphs::

	$ mkdir -p game/music/
	$ mkdir -p game/animations/
	$ touch game/game_states.asm game/music/music.asm game/animations/animations.asm game/chr_rom.asm

game/chr_rom.asm
----------------

This file contains the CHR-ROM. It is not directly a binary file, but contains instructions for XA to generate the binary. It allows adding comments to tiles. This file must generate the sprite tiles bank, followed by the nametable tiles bank.

Paste this contents::

	* = 0 ; We just use * to count position in the CHR-rom, begin with zero is easy

	; TILE $00 - Heart, frame 1
	;
	; 00100100
	; 01211210
	; 12222221
	; 01222210
	; 01222210
	; 00122100
	; 00122100
	; 00011000
	.byt %00100100, %01011010, %10000001, %01000010, %01000010, %00100100, %00100100, %00011000
	.byt %00000000, %00100100, %01111110, %00111100, %00111100, %00011000, %00011000, %00000000

	; TILE $01 - Heart, frame 2
	;
	; 00100100
	; 01311310
	; 13333331
	; 01333310
	; 01333310
	; 00133100
	; 00133100
	; 00011000
	.byt %00100100, %01111110, %11111111, %01111110, %01111110, %00111100, %00111100, %00011000
	.byt %00000000, %00100100, %01111110, %00111100, %00111100, %00011000, %00011000, %00000000

	#if $1000-* < 0
	#echo *** Error: VRAM bank1 data occupies too much space
	#else
	.dsb $1000-*, 0
	#endif

	; TILE $00 - Full backdrop color
	;
	; 00000000
	; 00000000
	; 00000000
	; 00000000
	; 00000000
	; 00000000
	; 00000000
	; 00000000
	.byt $00, $00, $00, $00, $00, $00, $00, $00
	.byt $00, $00, $00, $00, $00, $00, $00, $00

	; TILE $01 - Solid 1
	;
	; 11111111
	; 11111111
	; 11111111
	; 11111111
	; 11111111
	; 11111111
	; 11111111
	; 11111111
	.byt $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	.byt $00, $00, $00, $00, $00, $00, $00, $00

	#if $2000-* < 0
	#echo *** Error: VRAM bank2 data occupies too much space
	#else
	.dsb $2000-*, 0
	#endif

This file uses * (current address) and macros to add padding if necessary, so that you can define only the tiles that are actually needed. The rest of the CHR-ROM is automatically filled with zeros.

The *.byt* pseudo-op outputs raw bytes, ideal to generate the binary of the CHR-ROM. As it is still a source file, you can (and should) add comments describing your sprites and their use.

In the sample file you just pasted, there is two sprite tiles each representing a heart but with different colors. It will be used to make a blinking heart animation. There also is two nametable tiles, simple monochromatic ones, it can be used to create a background with big pixels.

game/animations/animations.asm
------------------------------

This file contains animations definitions. It is the static data, describing animation's frames. An animation frame is a collection of 8x8 sprites, shown for a certain duration. Looping over frames of an animation is made easy by the engine.

You need only one animation, the blinking heart. Let's describe it in this file::

	anim_heart:
	; Frame 1
	ANIM_FRAME_BEGIN(10)
	ANIM_SPRITE($00, $00, $00, $00) ; Y, tile, attr, X
	ANIM_FRAME_END
	; Frame 2
	ANIM_FRAME_BEGIN(10)
	ANIM_SPRITE($00, $01, $00, $00) ; Y, tile, attr, X
	ANIM_FRAME_END
	; End of animation
	ANIM_ANIMATION_END

As the animation is data that is stored somewhere in the PRG-ROM, you will need it's address, so begin with an easy to remember label. *anim_heart* is a perfect name for this animation and the label.

Using macros defined in nine-gine to describe the animation is nice to obtain an easy to read file. This animation is composed of two frames, each during 10 rendering frames (0.2 seconds) and is composed of a single sprite. The animation actually alternate colors of the heart.

game/game_states.asm
--------------------

This file describes routines associated to each game state.

It begins with a table of vectors pointing the routines of each state. As there is only one state to this game, there is one entry per table::

	; Subroutine called when the state change to this state
	game_states_init:
	VECTOR(ingame_init)

	; Subroutine called each frame
	game_states_tick:
	VECTOR(ingame_tick)

The initialization routine is in charge of drawing the screen's background. The easiest way to do this is to store the nametable in a compressed way::

	palettes_data:
	; Background
	.byt $20,$0d,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d
	; Sprites
	.byt $20,$06,$25,$22, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d

	nametable_data:
	.byt ZIPNT_ZEROS(32*7)
	.byt ZIPNT_ZEROS(32*7+12)
	.byt                                                                $01, $01, $01, $01,  $01
	.byt ZIPNT_ZEROS(15+12)
	.byt                                                                $01, $01, $01, $01,  $01
	.byt ZIPNT_ZEROS(15+12)
	;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
	.byt                                                                $01, $01, $01, $01,  $01
	.byt ZIPNT_ZEROS(15+32*7)
	.byt ZIPNT_ZEROS(32*6)
	nametable_attributes:
	.byt ZIPNT_ZEROS(8*8)
	.byt ZIPNT_END

The nametable in this format can be decompressed by an utility routine of Nine-gine.

Each frame, the heart has to be updated. It can move or change color at any time. To be able to draw it correctly you need to store somewhere its position and a counter to know which animation frame to draw. Let's attribute some space in zero page for this data::

	heart_x = $03
	heart_y = $04
	heart_anim_tick = $05

It begins at $03 since Nine-gine uses $00 to $02. You can read about labels used by Nine-gine in file *nine/mem_labels.asm*.

The initialization routine is pretty simple, as the nametable is stored on Nine-gine's format it is trivial to draw::

	; Initialization routine for ingame state
	ingame_init:
	.(
		; Point PPU to Background palette 0 (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
		lda PPUSTATUS
		lda #$3f
		sta PPUADDR
		lda #$00
		sta PPUADDR

		; Write palette_data in actual ppu palettes
		ldx #$00
		copy_palette:
		lda palettes_data, x
		sta PPUDATA
		inx
		cpx #$20
		bne copy_palette

		; Copy background from PRG-rom to PPU nametable
		lda #<nametable_data
		sta tmpfield1
		lda #>nametable_data
		sta tmpfield2
		jsr draw_zipped_nametable

		; Init the heart
		lda #$80
		sta heart_x
		sta heart_y
		lda #0
		sta heart_anim_tick

		rts
	.)

Finally, the tick routine must handle input and refresh the heart::

	; Tick routine for ingame state
	ingame_tick:
	.(
		;
		; Move the heart
		;

		; Check up button
		.(
			lda controller_a_btns
			and #CONTROLLER_BTN_UP
			beq ok

				dec heart_y

			ok:
		.)

		; Check left button
		.(
			lda controller_a_btns
			and #CONTROLLER_BTN_LEFT
			beq ok

				dec heart_x

			ok:
		.)

		; Check right button
		.(
			lda controller_a_btns
			and #CONTROLLER_BTN_RIGHT
			beq ok

				inc heart_x

			ok:
		.)

		; Check down button
		.(
			lda controller_a_btns
			and #CONTROLLER_BTN_DOWN
			beq ok

				inc heart_y

			ok:
		.)

		;
		; Draw the heart
		;

		; Name parameters of animation_draw
		param_x = tmpfield1
		param_y = tmpfield2
		param_animation_vector = tmpfield3
		param_first_sprite = tmpfield5
		param_last_sprite = tmpfield6
		param_direction = tmpfield7
		param_tick_number = tmpfield12

		; Place parameters for animation_draw
		lda heart_x
		sta param_x
		lda heart_y
		sta param_y
		lda #<anim_heart
		sta param_animation_vector
		lda #>anim_heart
		sta param_animation_vector+1
		lda #0
		sta param_first_sprite
		sta param_last_sprite
		sta param_direction
		lda heart_anim_tick
		sta param_tick_number

		; Draw the heart's animation
		jsr animation_draw

		; Save updated animation's tick number
		lda param_tick_number
		sta heart_anim_tick

		rts
	.)

Putting all these snippets to the file should be enough to make it work as intended

game/music/music.asm
--------------------

This file is the place for music data. Simply keep it empty, you may compose and integrate music later.

Build and play
--------------

If you followed the above steps, you should be able to build your first game. Simply assemble the *nine.asm* file on the top folder::

	$ xa xa nine.asm -C -o 'heart(E).nes'

Note the *(E)* in the *.nes* file name. ROMs produced by Nine-gine can run almost identically on PAL and NTSC systems, but their native system is PAL, indicating it in the filename helps most emulators to understand it.

Routines index
==============

absolute_a
----------

::

	 Change A to its absolute unsigned value

animation_draw
--------------

::

	 Draw the current frame of an animation
	  tmpfield1 - X position
	  tmpfield2 - Y position
	  tmpfield3, tmpfield4 - vector to the animation
	  tmpfield5 - index of the first OAM sprite to use
	  tmpfield6 - index of the last OAM sprite to use
	  tmpfield7 - direction of the animation (0 - natural, 1 - horizontally flipped)
	  tmpfield12 - current tick number

	 Set tmpfield12 to next tick number
	 Overwrite all refisters and tmpfields


audio_init
----------

audio_music_tick
----------------

audio_mute_music
----------------

audio_reset_music
-----------------

audio_unmute_music
------------------

boxes_overlap
-------------

::

	 Check if two rectangles collide
	  tmpfield1 - Rectangle 1 left
	  tmpfield2 - Rectangle 1 right
	  tmpfield3 - Rectangle 1 top
	  tmpfield4 - Rectangle 1 bottom
	  tmpfield5 - Rectangle 2 left
	  tmpfield6 - Rectangle 2 right
	  tmpfield7 - Rectangle 2 top
	  tmpfield8 - Rectangle 2 botto

	 tmpfield9 is set to #$00 if rectangles overlap, or to #$01 otherwise

call_pointed_subroutine
-----------------------

::

	 Allows to inderectly call a pointed subroutine normally with jsr
	  tmpfield1,tmpfield2 - subroutine to call

change_global_game_state
------------------------

::

	 Change the game's state
	  register A - new game state

	 WARNING - This routine never returns. It changes the state then restarts the main loop.

check_collision
---------------

::

	 Check if a movement collide with an obstacle
	  tmpfield1 - Original position X
	  tmpfield2 - Original position Y
	  tmpfield3 - Final position X (high byte)
	  tmpfield4 - Final position Y (high byte)
	  tmpfield5 - Obstacle top-left X
	  tmpfield6 - Obstacle top-left Y
	  tmpfield7 - Obstacle bottom-right X
	  tmpfield8 - Obstacle bottom-right Y
	  tmpfield9 - Final position X (low byte)
	  tmpfield10 - Final position Y (low byte)

	 tmpfield3, tmpfield4, tmpfield9 and tmpfield10 are rewritten with a final position that do not pass through obstacle.

check_top_collision
-------------------

::

	 Check if a movement passes through a line from above to under
	  tmpfield2 - Original position Y
	  tmpfield3 - Final position X (high byte)
	  tmpfield4 - Final position Y (high byte)
	  tmpfield5 - Obstacle top-left X
	  tmpfield6 - Obstacle top-left Y
	  tmpfield7 - Obstacle bottom-right X
	  tmpfield10 - Final position Y (low byte)

	 tmpfield3, tmpfield4, tmpfield9 and tmpfield10 are rewritten with a final position that do not pass through obstacle.

clrmem
------

copy_palette_to_ppu
-------------------

::

	 Copy a palette from a palettes table to the ppu
	  register X - PPU address LSB (MSB is fixed to $3f)
	  tmpfield1 - palette number in the table
	  tmpfield2, tmpfield3 - table's address

	  Overwrites registers

deactivate_particle_block
-------------------------

::

	Deactivate the particle block beginning at "particle_blocks, y"

draw_anim_frame
---------------

::

	 Draw an animation frame on screen
	  tmpfield1 - Position X
	  tmpfield2 - Position Y
	  tmpfield3, tmpfield4 - Vector pointing to the frame to draw
	  tmpfield5 - First sprite index to use
	  tmpfield6 - Last sprite index to use
	  tmpfield7 - Animation's direction (0 normal, 1 flipped)
	  tmpfield8 - X position
	  tmpfield9 - Y position

	 Overwrites tmpfield5, tmpfield8, tmpfield10, tmpfield14, tmpfield15 and all registers

draw_zipped_nametable
---------------------

::

	 Copy a compressed nametable to PPU
	  tmpfield1 - compressed nametable address (low)
	  tmpfield2 - compressed nametable address (high)

	 Overwrites all registers, tmpfield1 and tmpfield2

dummy_routine
-------------

::

	 A routine doing nothing, it can be used as dummy entry in jump tables

hide_particles
--------------

::

	 Hide all particles in the block beginning at "particle_blocks, y"

keep_input_dirty
----------------

::

	 Indicate that the input modification on this frame has not been consumed

last_nt_buffer
--------------

::

	 Set register X to the offset of the continuation byte of the first empty
	 nametable buffer

	 Overwrites register A

loop_on_particle_boxes
----------------------

::

	 Call a subroutine for each block
	  tmpfield1, tmpfield2 - address of the subroutine to call

	  For each call, Y is the offset of the block's first byte from particle_blocks

loop_on_particles
-----------------

::

	 Call a subroutine for each particle in a block
	  tmpfield1, tmpfield2 - address of the subroutine to call
	  Y - offset of the block's first byte from particle_blocks

	  For each call, Y is the offset of the particle's first byte and
	  tmpfield3 is the particle number (from 1)

multiply
--------

::

	 Multiply tmpfield1 by tmpfield2 in tmpfield3
	  tmpfield1 - multiplicand (low byte)
	  tmpfield2 - multiplicand (high byte)
	  tmpfield3 - multiplier
	  Result stored in tmpfield4 (low byte) and tmpfield5 (high byte)

	  Overwrites register A, tmpfield4 and tmpfield5

number_to_tile_indexes
----------------------

::

	 Produce a list of three tile indexes representing a number
	  tmpfield1 - Number to represent
	  tmpfield2 - Destination address LSB
	  tmpfield3 - Destionation address MSB

	  Overwrites timfield1, timpfield2, tmpfield3, tmpfield4, tmpfield5, tmpfield6
	  and all registers.

particle_draw
-------------

::

	 Draw particles according to their state

particle_handlers_reinit
------------------------

::

	 Deactivate all particle handlers

process_nt_buffers
------------------

::

	 Copy nametable buffers to PPU nametable
	 A nametable buffer has the following pattern:
	   continuation (1 byte), address (2 bytes), number of tiles (1 byte), tiles (N bytes)
	   continuation - 1 there is a buffer, 0 work done
	   address - address where to write in PPU address space (big endian)
	   number of tiles - Number of tiles in this buffer
	   tiles - One byte per tile, representing the tile number

	 Overwrites register X and tmpfield1

reset_nt_buffers
----------------

::

	 Empty the list of nametable buffers

shake_screen
------------

signed_cmp
----------

::

	 Perform multibyte signed comparison
	  tmpfield6 - a (low)
	  tmpfield7 - a (high)
	  tmpfield8 - b (low)
	  tmpfield9 - b (high)

	 Output - N flag set if "a < b", unset otherwise
	          C flag set if "(unsigned)a < (unsigned)b", unset otherwise
	 Overwrites register A

wait_next_frame
---------------

::

	 Wait the next 50Hz frame, returns once NMI is complete
	  May skip frames to ensure a 50Hz average

wait_next_real_frame
--------------------

::

	 Wait the next frame, returns once NMI is complete
