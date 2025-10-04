#!/bin/bash
ft()
{
    if [[ $1 == "-h" || $1 == "--help" ]]; then
        cat ~/.utilc/.man/ft.txt
        return 0
    fi

    if [[ $# -ne 2 ]]; then
        echo "syntax ERROR. please read this command help --> ft -h or --help"
        return 1
    fi

    number="$1"
    probname="$2"
    shift 2

    mkdir -p "$number"

    # single command
    if [[ $# -eq 0 ]]; then
        # ft file
        cat ~/.utilc/.tmp/tmp.txt > "$number"/"$probname".c

        # .main file
        echo -e "#define __SCRIPT__ \"$probname.c\"" > "$number"/.main.c
        {
            echo "#define __SCRIPT__ \"$probname.c\""
            sed "s|{UTILC}|\"$HOME/.utilc/util.h\"|g" ~/.utilc/.tmp/.main.txt
        } > "$number/.main.c"
    fi

    # with option
    for opt in "$@"; do
        case "$opt" in
            -m|--make)
                # with makefile
                ftmake "$number"
                ;;
            -f|--files)
                # generate multiple files
                shift
                for fname in "$@"; do
                    cat ~/.utilc/.tmp/tmp.txt > "$number"/"$fname".c
                done
                break
                ;;
            *)
                echo "unknown option: $opt"
                ;;
        esac
    done
}

ftall()
{
    if [[ $1 == "-h" || $1 == "--help" ]]; then
        cat ~/.utilc/.man/ftall.txt
        return 0
    fi

    if [[ $1 == "-v" || $1 == "--valgrind" ]]; then
        for f in ex*; do
            valgc "$f"
            echo
        done
        return 0
    fi

    for f in ex*; do
        gcc -g -Wall -Wextra -Werror $f/*.c $f/.main.c $HOME/.utilc/util.c && ./a.out
        echo
    done

    rm -rf a.out
}

ftmake() {
    if [[ $1 == "-h" || $1 == "--help" ]]; then
        cat ~/.utilc/.man/ftmake.txt
        return 0
    fi

    dir="."
    if [[ -n $1 ]]; then
        dir="$1"
    fi

    cat > "$dir"/Makefile << 'EOF'
NAME = a.out
CC = gcc
CFLAGS = -g -Wall -Wextra -Werror

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
EOF
    echo "Makefile created in $dir/"
}


valgc()
{
    target="."

    if [[ $1 == "-h" || $1 == "--help" ]]; then
        cat ~/.utilc/.man/valgc.txt
        return 0
    fi

    if [[ $# -gt 1 ]]; then
        echo "syntax ERROR. please read this command help --> ft -h or --help"
        return 1
    elif [[ $# -eq 1 ]]; then
        target="$1"
    fi

    gcc -g -Wall -Wextra -Werror $target/*.c $target/.main.c $HOME/.utilc/util.c
    # -g ... 行番号や変数名を実行ファイルに埋め込む。valgrindが処理を追跡する際に行番号を付記して表示してくれるようになる

    valgrind --track-origins=yes --track-fds=yes --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all ./a.out
    # --track-origins=yes ... 未初期化メモリを使った場合に、どこでその値が生成されたかを追跡
    # --track-fds=yes ... ファイルディスクリプタの開閉を追跡
    # --leak-check=full ... メモリリークを詳細にチェック。どこでメモリが解放されなかったかを表示する
    # --show-leak-kinds=all ... リークの種類をすべて表示。[definite]未解放 [indirect]間接的リーク など
    # --errors-for-leak-kinds=all ... 指定した種類のリークがある場合、終了コードを非ゼロに設定

    rm -rf a.out
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

    # switch option
    case "$1" in
        -l|--list)
            ls ~/.utilc/snippets
            return 0
            ;;
        -e|--edit)
            if [[ -z $2 ]]; then
                echo "please specify snippet name"
                return 1
            fi
            vim ~/.utilc/snippets/"$2".c
            return 0
            ;;
        -add)
            if [[ -z $2 ]]; then
                echo "please specify new snippet name"
                return 1
            fi
            cp ~/.utilc/.tmp/tmp.txt ~/.utilc/snippets/"$2".c
            vim ~/.utilc/snippets/"$2".c
            return 0
            ;;
        *)
            if [[ -f ~/.utilc/snippets/"$1".c ]]; then
                cat ~/.utilc/snippets/"$1".c
            else
                echo "snippet not found: $1"
                return 1
            fi
            return 0
            ;;
    esac

    # insert snippets
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