# Shared helper for non-tmux launchers: print the by-hand watcher / pair / term commands.
# Reads the launcher contract (WORKSHOP_*) from the environment. Sourced, not executed.

print_workshop_steps() {
  echo "  Watcher (TDD loop):  cd \"$WORKSHOP_SLICE_DIR\" && \"$WORKSHOP_ROOT/bin/watch\""
  if [[ -n "${WORKSHOP_AI_CMD:-}" ]]; then
    echo "  AI pair:             cd \"$WORKSHOP_SLICE_DIR\" && $WORKSHOP_AI_CMD"
  fi
  if [[ -n "${WORKSHOP_TERM_CMD:-}" ]]; then
    echo "  Term:                cd \"$WORKSHOP_TARGET_DIR\" && $WORKSHOP_TERM_CMD"
  fi
}
