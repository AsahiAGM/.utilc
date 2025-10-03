#!/bin/bash
ft()
{
    if [[ $1 == "-h" || $1 == "--help" ]]; then
        cat ~/.utilc/.man/ft.txt
        return 0
    fi

    if [[ $# -ne 1 ]]; then
        echo "syntax ERROR. please read this command help --> ft -h or --help"
        return 1
    fi

    probname="$1"
    cat ~/.utilc/.tmp/tmp.txt > "$probname".c
    echo -e "#define __SCRIPT__ \"$probname.c\"" > .main.c
    cat ~/.utilc/.tmp/.main.txt >> .main.c
}

snip()
{
    if [[ $1 == "-h" || $1 == "--help" ]]; then
        cat ~/.utilc/.man/snip.txt
        return 0
    fi
    if [[ $# -ne 3 ]]; then
        echo "syntax ERROR. please read this command help --> snip -h or --help"
        return 1
    fi

    snippet="$1"
    col=${2:-0}
    target="$3".c
    snippet_path="$HOME/.utilc/snippets/${snippet}.txt"

    if [ ! -f "$snippet_path" ]; then
        echo "Snippet $snippet_path not found!"
        return 1
    fi

    if [ "$col" -eq 0 ]; then
        # 先頭に挿入
        cat "$snippet_path" "$target" > "$target.tmp" && mv "$target.tmp" "$target"
    else
        # 指定行に挿入
        sed -i "${col}r $snippet_path" "$target"
    fi
    echo "Inserted $snippet into $target at line $col"
}