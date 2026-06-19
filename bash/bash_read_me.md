
---

# Bash Scripting & CLI Quick Revision Guide

A comprehensive, scannable revision document for Bash scripting, core built-ins, and Linux CLI utilities.

---

## 1. Essentials & Variables

### Shebang & Comments

```bash
#!/usr/bin/env bash
# This is a comment. The line above is the Shebang (interpreting directive).

```

### Variable Assignment & Syntax

```bash
variable="Some string"   # Correct: No spaces around '='
# variable = "String"    # WRONG: Interprets 'variable' as a command
# variable= "String"     # WRONG: Scope assignment failure

echo "$variable"         # Output: Some string (Double quotes expand variables)
echo '$variable'         # Output: $variable  (Single quotes interpret literally)

```

### Parameter Expansion & String Manipulation

```bash
echo "${variable}"       # Basic parameter expansion

# String Substitution
echo "${variable/Some/A}" # Output: "A string" (Replaces first match)

# Substrings
length=7
echo "${variable:0:length}" # Output: "Some st" (Slicing)
echo "${variable: -5}"      # Output: "tring"   (Negative offset requires leading space)

# String Length
echo "${#variable}"      # Output: 11

# Indirect & Default Values
other_var="variable"
echo ${!other_var}       # Output: "Some string" (Indirect expansion)
echo "${foo:-"Default"}" # Returns "Default" if $foo is unassigned/null

```

---

## 2. Data Structures: Arrays

```bash
# Declaration
array=(one two three four five six)

# Accessing Elements
echo "${array[0]}"       # Output: "one"
echo "${array[@]}"       # Output: "one two three four five six" (All elements)
echo "${#array[@]}"      # Output: "6" (Array length)
echo "${#array[2]}"      # Output: "5" (Length of the 3rd element)
echo "${array[@]:3:2}"   # Output: "four five" (Slicing: offset 3, length 2)

# Iteration
for item in "${array[@]}"; do
    echo "$item"
done

```

---

## 3. Special Built-in Variables

| Variable | Description |
| --- | --- |
| `$?` | Exit status of the last executed foreground pipeline / program |
| `$$` | Process ID (PID) of the current script |
| `$#` | Number of arguments passed to the script |
| `$@` | All arguments passed to the script as individual strings |
| `$1, $2...` | Positional parameters (Script inputs) |
| `$PWD` | Current working directory (Equivalent to `$(pwd)`) |

---

## 4. Brace Expansion & I/O

### Brace Expansion (Generates Strings)

```bash
echo {1..10}             # Output: 1 2 3 4 5 6 7 8 9 10
echo {a..z}             # Output: a b c d e f g h ... z
# Note: Variables cannot be used inside brace expansions (e.g., {$from..$to} fails)

```

### Reading Input

```bash
echo "What's your name?"
read name                # Stores user entry dynamically into $name

```

---

## 5. Conditionals & Logic

### If Statements & Operators

```bash
# String Comparisons
if [[ "$name" != "$USER" ]]; then
    echo "Your name isn't your username"
fi

# Logical Operators (AND / OR require separate evaluation blocks)
if [[ "$name" == "Steve" ]] && [[ "$age" -eq 15 ]]; then
    echo "Runs if BOTH conditions are true"
fi

if [[ "$name" == "Daniya" ]] || [[ "$name" == "Zach" ]]; then
    echo "Runs if EITHER condition is true"
fi

```

### Numeric Comparison Operators

* `-eq` : Equal to
* `-ne` : Not equal to
* `-lt` : Less than
* `-gt` : Greater than
* `-le` : Less than or equal to
* `-ge` : Greater than or equal to

### Regex Matching

```bash
email="me@example.com"
if [[ "$email" =~ [a-z]+@[a-z]{2,}\.(com|net|org) ]]; then
    echo "Valid email!"
fi

```

### Short-Circuit Execution

```bash
command1 || command2     # command2 runs ONLY if command1 FAILS (exit status != 0)
command1 && command2     # command2 runs ONLY if command1 SUCCEEDS (exit status == 0)

```

---

## 6. Job Control & Process Management

```bash
sleep 30 &               # Appending '&' runs command in background
jobs                     # Lists active background jobs
fg                       # Brings the most recent background job to foreground
bg                       # Resumes a suspended (Ctrl+Z) job in the background
kill %2                  # Terminate job number 2

```

---

## 7. Arithmetic & Directory Control

### Arithmetic Evaluation

```bash
echo $(( 10 + 5 ))       # Output: 15

```

### Navigation Shortcuts

```bash
cd ~       # Go to Home directory
cd -       # Toggle back to the last visited directory
cd ..      # Step up one parent directory

```

### Subshells

```bash
# Running commands inside ( ) executes them in a temporary child process sandbox
(cd /tmp; touch sandbox.txt)
pwd        # Still in the original execution directory; context was preserved!

```

---

## 8. Streams, Redirections, & Pipelines

### Redirection Operators

```bash
python script.py < input.in            # Redirect file contents to stdin
python script.py > output.out          # Overwrite stdout to file
python script.py 2> error.err          # Redirect stderr (File descriptor 2) to file
python script.py > log.log 2>&1        # Redirect both stdout and stderr to log.log
python script.py > /dev/null 2>&1      # Discard all outputs completely
python script.py >> output.out         # Append stdout instead of overwriting

```

### Here Documents (Heredoc)

```bash
# Write blocks of multi-line strings directly into a file
cat > hello.py << EOF
#!/usr/bin/env python
print("Hello World")
EOF

```

### Process Substitution

```bash
cat > output.out <(echo "#helloworld") # Pass output of a command as a file stream

```

---

## 9. Control Flow: Loops & Switch Cases

### Case (Switch) Statement

```bash
case "$Variable" in
    0) echo "There is a zero.";;
    1) echo "There is a one.";;
    *) echo "Fallback: Match everything else.";;
esac

```

### For Loops

```bash
# Range iteration
for Var in {1..3}; do echo "$Var"; done

# C-Style iteration
for ((a=1; a <= 3; a++)); do echo $a; done

# File iteration
for Output in ./*.markdown; do cat "$Output"; done

```

### While Loops

```bash
while [ true ]; do
    echo "Looping..."
    break                # Graceful termination
done

```

---

## 10. Reusable Functions

```bash
# Definition Syntax
function foo() {
    echo "Arguments: $@" # Access all arguments passed to function
    echo "First Arg: $1" # Access individual positional parameter
    return 0             # Returns numeric exit status code (0-255)
}

# Alternative Declaration
bar() {
    echo "Another clean declaration way!"
}

# Execution
foo "Arg1" "Arg2"
resultValue=$?           # Capture function exit status code

```

---

## 11. Crucial CLI Utilities for Interviews

### File Filtering & Text Parsing

* `tail -n 10 file.txt` : Returns the last 10 lines of a file.
* `head -n 10 file.txt` : Returns the first 10 lines of a file.
* `sort file.txt` : Sorts lines alphabetically.
* `uniq -d file.txt` : Isolates and reports duplicate lines.
* `cut -d ',' -f 1 file.txt` : Parsed data parser; splits by comma and extracts the first column field.

### In-place Processing with Sed

```bash
sed -i 's/okay/great/g' file.txt   # Global string replacement modifying file immediately

```

### Pattern Matching with Grep

```bash
grep "^foo.*bar$" file.txt         # Filters lines matching regex
grep -c "^foo" file.txt            # Outputs match count instead of lines
grep -r "target" someDir/          # Recursive directory text search
grep -v "exclude" file.txt         # Inverse match (shows lines NOT containing query)

```

### Advanced System Tools

```bash
trap "rm $TEMP_FILE; exit" SIGHUP SIGINT SIGTERM  # Catch system signals to execute cleanup
alias ping='ping -c 5'                            # Create CLI command alias shortcuts
\ping 192.168.1.1                                 # Escape character bypasses active alias

```

### Getting Help

* `help <command>` : Documentation for built-in shell structures.
* `man <command>` : Reference manuals for Linux binaries.
* `info <command>` : In-depth menu-driven system documentation.