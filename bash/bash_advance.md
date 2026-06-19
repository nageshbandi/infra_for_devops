
---

# Bash Advanced Scripting & CLI Reference Guide

A categorized revision artifact designed for rapid interview preparation focusing on advanced Bash features, control flow, parameter manipulation, and shell execution modes.

---

## 1. Shell Invocation Flags (`tldr:bash`)

When starting or testing a script, how you invoke the shell matters. These flags often come up in troubleshooting or security questions.

```bash
bash                         # Starts a standard interactive shell session
bash --norc                  # Starts an interactive session WITHOUT loading startup configs (.bashrc, etc.)
bash -c "commands"           # Executes specific commands passed directly as a string
bash -x path/to/script.sh    # Debug Mode: Prints each command before execution
bash -e path/to/script.sh    # Fail-Fast Mode: Aborts script immediately at the first error (exit status > 0)
echo "echo 'hello'" | bash   # Executes commands directly injected via stdin

```

---

## 2. Advanced Control Flow & Logic

### Case Statements

Useful for pattern matching against positional arguments (`$1`) or menu selections. Use `;;` to terminate a clause and `*)` as the catch-all.

```bash
case "$1" in
    0)   echo "Found exactly 0." ;;
    1|2) echo "Found 1 or 2." ;;
    3*)  echo "Matches anything beginning with '3'." ;;
    '')  echo "Value is null or empty." ;;
    *)   echo "Matches anything else." ;;
esac

```

### For Loops (Multi-line & One-liners)

```bash
# Globbing Loop: Iterates over files in the current directory
for file in *; do
    echo "$file found"
done

# List Iteration
for CurDay in Monday Tuesday Wednesday Thursday Friday; do
    printf "Weekday: %s\n" "$CurDay"
done

# Range One-liners
for CurIter in {1..4}; do echo "$CurIter"; done
for CurIter in {1..4}; { echo "$CurIter"; }      # Alternative cleaner syntax

```

### Integer Comparison Testing

```bash
if [ $var -eq 0 ]; then
    printf "Variable is equal to integer 0\n"
fi

```

---

## 3. String & Parameter Expansion Mastery

This is highly testable in technical interviews when assessing your text manipulation skills without relying on heavy external binaries like `sed` or `awk`.

### Array & Length Mechanics

```bash
${Var[0]}      # Accesses index 0 of an array (0-indexed default)
${Var[2+3]}    # Evaluates arithmetic inside array indexing (Accesses index 5)
${#Var}        # Returns character length of the string inside $Var
${#Var[@]}     # Returns the total number of elements/indices inside an array

```

### Substrings & Pattern Stripping

```bash
${Var:2:1}     # Substring: ${variable:offset:length} (e.g., "thing" with offset 2, length 1 becomes "i")

# Pattern Stripping (Mnemonic: # matches the Left/Front of a path, % matches the Right/Back)
${Var#*[Tt]}   # Non-greedy strip: Removes shortest match from Left to Right up to 'T' or 't'
${Var##*[Tt]}  # Greedy strip: Removes longest match from Left to Right 
${Var%[Tt]*}   # Non-greedy strip: Removes shortest match from Right to Left
${Var%%[Tt]*}  # Greedy strip: Removes longest match from Right to Left

```

### Regex-Free Search & Replace (Glob Pattern Substitution)

```bash
${Var/PATTERN/REPLACEMENT}   # Replaces the FIRST occurrence of PATTERN
${Var//PATTERN/REPLACEMENT}  # Greedy: Replaces ALL occurrences of PATTERN

# Real-world usage: Convert colon-separated $PATH into space-separated elements for find
find ${PATH//:/ } -type d

```

### Defaults, Fallbacks, & Transformations

```bash
${Var:-Default Value}        # Evaluates to "Default Value" if $Var is unset or null (Does not re-assign)
${Var:?Error Message}        # Exits script with status 1 and prints "Error Message" if $Var is empty

${!Var}                      # Indirect expansion (If Var="OtherVar" and OtherVar="true", returns "true")

${Var^}                      # Capitalizes the first character
${Var^^}                     # Converts the entire string to UPPERCASE
${Var,}                      # Lowercases the first character
${Var,,}                     # Converts the entire string to lowercase

```

---

## 4. Advanced Stream Redirections & Pipelines

### Standard Redirections

```bash
COMMAND > FILE 2>&1          # Redirects both STDOUT (1) and STDERR (2) to FILE
COMMAND > /dev/null 2>&1     # Silent execution: Discards both STDOUT and STDERR

COMMAND_1 |& COMMAND_2       # Bash Shortcut: Pipes both STDOUT and STDERR of COMMAND_1 into COMMAND_2

```

### Capturing Individual Pipeline Exit Codes

In a standard pipeline (`cmd1 | cmd2`), `$?` only returns the exit status of `cmd2`. To find out if `cmd1` or intermediate tools failed, look at the `${PIPESTATUS[@]}` array.

```bash
printf 'foo' | grep -F 'foo' | sed 's/foo/bar/'

echo ${PIPESTATUS[0]}        # Exit status of printf
echo ${PIPESTATUS[1]}        # Exit status of grep
echo ${PIPESTATUS[2]}        # Exit status of sed

```

---

## 5. Script Hardening & Operational Tricks

### In-Script Debugging (Tracing)

Toggle tracing dynamically inside a script block to print commands as they are processed without changing how you invoke the script file.

```bash
set -x                       # Enable verbose execution debugging output
# ... code to debug ...
set +x                       # Disable debugging output

```

### Binary Dependency Validation

Safer alternatives to verify if a third-party command line dependency exists inside your runner context or system path before continuing.

```bash
# Bourne Shell compatible verification
command -v terraform >/dev/null 2>&1 || { echo "Missing dependency"; exit 1; }

# Bash-native explicit type verification
if ! type -fP bash > /dev/null 2>&1; then
    printf "ERROR: Dependency 'bash' not met." >&2
    exit 1
fi

```

### Native Atomicity: File Locking

Uses the `noclobber` shell option to safely prevent file overwriting. If the file exists, the creation statement fails atomically. Excellent for ensuring single-instance execution of automation crons.

```bash
( set -o noclobber; echo $$ > my.lock ) || { echo 'Failed to create lock file: Instance already running'; exit 1; }

```

### Text Mass-Manipulation

```bash
# Verbosely (-v) converts spaces to underscores in filenames without overwriting (-n)
for name in *\ *; do mv -vn "$name" "${name// /_}"; done

```

---

## 6. High-Risk Vulnerabilities (What NOT to do)

Be prepared to explain *why* these behaviors break Linux operating kernels during interview architecture discussions.

### Fork Bomb

An obfuscated function that recursively calls itself in parallel execution paths, starving the OS processing table until system crash or locking.

```bash
:(){ :|:& };:
# Explanation: Defines a function named ':', which pipes into itself, 
# backgrounds the execution context (&), and immediately triggers the initial call.

```

### Root File-Deletion Overwrite (Unix Roulette)

```bash
[ $[ $RANDOM % 6 ] == 0 ] && rm -rf /* || echo Click
# Note: Modern safeguards require explicit `--preserve-root` bypasses to block this catastrophe, 
# but it illustrates the extreme danger of cascading dynamic script strings with raw `rm -rf` evaluation blocks.

```