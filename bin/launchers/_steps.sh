# Shared helper for non-tmux launchers: print the by-hand watcher / pair / term commands.
# Reads the launcher contract (WORKSHOP_*) from the environment. Sourced, not executed.

print_workshop_steps() {
  if [[ "${WORKSHOP_WATCH:-1}" != "0" ]]; then
    echo "  Watcher (TDD loop):  cd \"$WORKSHOP_SLICE_DIR\" && \"$WORKSHOP_ROOT/bin/watch\""
  else
    echo "  Discovery:           no watcher yet. Scout mode has no red/green loop; research, then drill."
  fi
  if [[ -n "${WORKSHOP_AI_CMD:-}" ]]; then
    echo "  AI pair:             cd \"$WORKSHOP_SLICE_DIR\" && $WORKSHOP_AI_CMD"
  fi
  if [[ -n "${WORKSHOP_TERM_CMD:-}" ]]; then
    echo "  Term:                cd \"$WORKSHOP_TARGET_DIR\" && $WORKSHOP_TERM_CMD"
  fi
}
