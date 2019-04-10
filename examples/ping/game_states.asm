; Subroutine called when the state change to this state
game_states_init:
VECTOR(title_screen_init)
VECTOR(ingame_init)

; Subroutine called each frame
game_states_tick:
VECTOR(title_screen_tick)
VECTOR(ingame_tick)

#define GAME_STATE_TITLE 0
#define GAME_STATE_INGAME 1

#include "game/title_screen.asm"
#include "game/ingame.asm"
