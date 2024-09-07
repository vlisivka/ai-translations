#!/bin/bash
. import.sh strict log arguments

DEBUG_REASONING="no" # Set to yes to turn step-by-step reasoning
LANGUAGE="Ukrainian"
CUSTOM_PROMPT=""

NL=$'\n' # New line

# Ask AI to critique the translation.
critic() {
    local message="$1"
    {
      echo "Below is translation of message in PO formtat enclosed in <message></message> tag, which must be reviewed and validated for correctness of translation."
      echo "Then additional instructions follow in <instruction></instruction> tag."
      echo "<message>$message</message>"
      echo "<instruction>"
      echo "Respond in $LANGUAGE language."
      echo "As professional technical localizator of software, carefuly understand the message and it translation, then try to find flaws in it,"
      echo "such typos in translated words, incorrect suffixes, incorrect terms, too verbatim translations, bad choice of words, ambiguity, etc."
      echo "First: copy verbatim the original message and it translation in <message>original \"msgid\" and \"msgstr\" fields</message>. This is important for reviewing process."
      [ "$DEBUG_REASONING" == "no" ] || echo "Then write <steps>step-by-step reasoning about translation only and selection of words in translation</steps>."
      echo "If translation is incorrect or contains flaws, then write <comments>comment about the error and how to fix it</comments>,"
      echo "then <fix>Correct translation of the original message to \"$LANGUAGE\" language</fix>."
      echo "Write <result>result</result> is translation correct or flawed."
      echo "If you uncertain or need additional data to answer the question, write them in <needs-answers>request</need-answers>."
      echo "The order of tags in result is:"
      echo "<message> verbatim copy of original message and it transalation (important)</message>"
      [ "$DEBUG_REASONING" == "no" ] || echo "<steps>step-by-step reasoning of 3 different experts about translation only: expert in translation to \"$LANGUAGE\" lanugage, expert in techincal tranlsations and localization, and expert in programming"
      [ "$DEBUG_REASONING" == "no" ] || echo "Expert in translation should watch out for natural soundness of tranlation, correct translation of words, idioms, and correct order of words (because order of words is swapped between Ukrainain and English language in many cases)."
      [ "$DEBUG_REASONING" == "no" ] || echo "Expert in technical transation and localization should watch out for correct usage of technical terms, and use technical terms when need, to preserve the meaning."
      [ "$DEBUG_REASONING" == "no" ] || echo "Expert in programming must watch out that technical symbols, such as placeholds, quotes, operators, or special symbols, are preserved, so program will work correctly after translation.</steps>"
      echo "<comments>comments about translation only</comments>"
      echo "<result>Trabslation is correct/Translation is flawed</result>"
      echo "<fix>corrected technical translation</fix>"
      echo "<correct-message>verbatim copy of original msgid field and msgstr field with proper translation (important) and without other tags</correct-message>"

      echo "${CUSTOM_PROMPT:-}"
      echo "</instruction>"
      echo "Start with original <message>:"
    } | aichat -r crit-po-uk

}

main() {
  if [ $# -lt 1 ]; then
    echo "Usage: $0 messages.po..."
    exit 1
  fi

  # For all files with messages
  for messages_file in "$@"
  do
    local answers_file="${messages_file%.md}-critique.md" # File to store answers into

    # Read mesages separated by empty line one by one
    {
      local message="" # A single message from PO file

      # Critique paragraph by paragraph
      while IFS= read -r line; do
        (( ${#line} == 0 )) || message="$message$line$NL"

        if (( ${#line} == 0 ))
        then
          critic "$message"
          message=""
        fi
      done

      # Critique last paragraph
      [ -z "$message" ] || critic "$message"

      echo ""
    }< "$messages_file" | tee "$answers_file"


  done
}

arguments::parse \
   "-d|--debug-reasoning)DEBUG_REASONING;Yes" \
   "-l|--language)LANGUAGE;String" \
   "-c|--custom-prompt)CUSTOM_PROMPT;String" \
   -- \
   "${@:+$@}"

main "${ARGUMENTS[@]}" || panic "Command failed with arguments \"${ARGUMENTS[*]}\"." || exit $?

exit 0

#>> Critique translations of messages in PO file.
#>>
#>> Usage: crit-po-uk.sh [OPTIONS] MESSAGES_FILE[...]
#>>
#>> Options:
#>>   -h | --help  show this help text.
#>>   --man        show documentation.
#>>   -d | --debug-reasoning        Turn on step-by-step reasoning in comments.
#>>   -l | --language LANGUAGE      Ask AI to respond in given LANGUAGE. Default value: "Ukrainian".
#>>   -c | --custom-prompt TEXT     Add this text to the prompt.
