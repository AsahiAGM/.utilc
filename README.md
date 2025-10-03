# .utilc
## Summary
### utility functions
make it usable any utility functions by "#include "{path}/.util.h".
Please refer to util.c for the function contents.

### usable snippets
Many complex functions and operations can be called and inserted by specifying the item.
Please check the snippets folder for the implemented processes.
The command to call a snippet is snip. For usage, use -h or --help.
(To enable the snip command, you must source util.sh.)

## Setup / Download

1. Default (read-only usage)
To install for read-only usage (the `.git` directory will be removed):

```bash
bash <(curl -s https://raw.githubusercontent.com/AsahiAGM/.utilc/main/setup.sh)
```

- ft, valgc, snip, etc. are immediately available
- .utilc .git directory is removed to prevent accidental pushes

2. Development mode (--dev)
To participate in development and contribute new features:

```bash
bash <(curl -s https://raw.githubusercontent.com/AsahiAGM/.utilc/main/setup.sh) --dev
```

- .git is preserved for editing and pushing changes
- You can add new snippets or modify util.sh

3. Local clone method
If you prefer to manually clone:

```bash
git clone https://github.com/AsahiAGM/.utilc.git ~/.utilc
```
- bash ~/.utilc/setup.sh          # read-only usage
- bash ~/.utilc/setup.sh --dev    # development mode

Notes:
- ~/.bashrc will be automatically updated to source util.sh
- After setup, functions like ft, valgc, and snip can be used immediately
