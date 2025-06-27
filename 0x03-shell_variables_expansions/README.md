# 0x03. Shell, init files, variables and expansions

## 📁 Directory
**Project Directory:** `0x03-shell_variables_expansions`  
**GitHub Repository:** `alx-system_engineering-devops`

---

## 📝 Description

This project is focused on :
- understanding and manipulating shell initialization files
- variables (local and global)
- environmental settings
- shell arithmetic/expansions.

## How to Usage

Make the scripts executable:

```bash
chmod +x <script_name>

---

## 📝 Files and Scripts

This directory contains a series of Bash scripts, each designed to demonstrate key concepts in shell variable management, environment configuration, and basic shell operations. Below is a summary of what each script does:

| Script | Description |
|--------|-------------|
| `0-alias` | Defines a shell alias named `ls` that, when invoked, executes the command `rm *`, effectively deleting all files in the current directory. **⚠️ Dangerous in practice** and should be handled with care. |
| `1-hello_you` | Displays a personalized greeting in the format `hello user`, where `user` is dynamically determined using the current Linux user's name. |

| `2-path` | Modifies the `PATH` environment variable by appending the directory `/action` at the end, making it the last location searched when executing commands. |

| `3-paths` | Parses the current value of the `PATH` variable and prints the number of individual directories it contains, helping visualize how many places the shell checks for executables. |

| `4-global_variables` | Outputs a list of all currently defined global (environment) variables using shell built-ins such as `printenv` or similar methods. |

| `5-local_variables` | Lists all shell variables — including local variables, environment variables, and user-defined shell functions — for a complete view of the shell’s context. |

| `6-create_local_variable` | Declares a **local** variable named `BEST` and assigns it the value `School`. This variable will only exist within the scope of the current shell session or function. |

| `7-create_global_variable` | Defines a **global (environment)** variable named `BEST` with the value `School`, making it available to child processes and external scripts. |

| `8-true_knowledge` | Reads the value of an environment variable `TRUEKNOWLEDGE`, adds 128 to it, and prints the result. This demonstrates basic arithmetic using environment variables. |

| `9-divide_and_rule` | Divides the value of `POWER` by `DIVIDE`, both provided as environment variables, and prints the result. Useful for practicing arithmetic operations with dynamic inputs. |

| `10-love_exponent_breath` | Calculates the exponentiation of two environment variables — raises `BREATH` to the power of `LOVE` — and prints the result. |

| `11-binary_to_decimal` | Converts a binary number (stored in the environment variable `BINARY`) to its decimal equivalent and outputs the result. |

| `12-combinations` | Prints all lowercase alphabetical two-letter combinations (from `aa` to `zz`), **excluding** the pair `oo`. The output is sorted and formatted one combination per line. |

| `13-print_float` | Reads a numeric value from the environment variable `NUM` and prints it with exactly **two decimal places**, regardless of its original format. |

---

