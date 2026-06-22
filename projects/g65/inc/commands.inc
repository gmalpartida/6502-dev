
	.include "stddefs.inc"

	.global is_poke_cmd
	.global is_peek_cmd
	.global is_reset_cmd
	.global is_clear_cmd
	.global is_dump_cmd
	.global is_load_cmd
	.global is_goto_cmd

	.global process_peek_cmd
	.global process_poke_cmd
	.global process_reset_cmd
	.global process_clear_cmd
	.global process_dump_cmd
	.global process_unknown_cmd
	.global process_load_cmd
	.global process_goto_cmd

	.global get_cmd_line
	.global get_cmd
	.global print_cmd
