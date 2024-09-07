#!/bin/bash
. import.sh strict log arguments

# Extract untranslated messages from .po file
extract_untranslated_messages() {
  local ORIGINAL_FILE="${1?:File to extract untranslated messages from is required.}"
  local UNTRANSLATED_MESSAGES_FILE="${2:?File to write untranslated messages into is required.}"
  info "Extracting untranslated messages from \"$ORIGINAL_FILE\" into \"$UNTRANSLATED_MESSAGES_FILE\"."
  msgattrib --untranslated "$ORIGINAL_FILE" -o "$UNTRANSLATED_MESSAGES_FILE" \
    || panic "Cannot extract untranslated messages from \"$ORIGINAL_FILE\" into \"$UNTRANSLATED_MESSAGES_FILE\"."
}

extract_untranslated_messages "$@" || panic "Cannot extract untranslated messages."
