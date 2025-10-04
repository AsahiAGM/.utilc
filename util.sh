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
    # switch option
    case "$1" in
        -h|--help)
            cat ~/.utilc/.man/snip.txt
            return 0
            ;;
        -l|--list)
            ls ~/.utilc/snippets | xargs -n 1 basename -s .txt
            return 0
            ;;
        -e|--edit)
            if [[ -z $2 ]]; then
                echo "please specify snippet name"
                return 1
            fi
            vim ~/.utilc/snippets/"$2".txt
            return 0
            ;;
        -add)
            if [[ $# -lt 3 ]]; then
                echo "please target filename and specify new snippet name"
                return 1
            fi
            cp "$2" ~/.utilc/snippets/"$3".txt
            vim ~/.utilc/snippets/"$3".txt
            return 0
            ;;
        -m|--multi)
            if [[ $# -lt 4 ]]; then
                echo "Usage: snip -m [target filename] [line number] [snippet1 snippet2 ...]"
                return 1
            fi

            target="$2".c
            col="$3"
            shift 3

            if [[ ! -f "$target" ]]; then
                echo "Target file not found: $target"
                return 1
            fi

            for snippet in "$@"; do
                snippet_path="$HOME/.utilc/snippets/${snippet}.txt"
                if [[ ! -f "$snippet_path" ]]; then
                    echo "Warning: snippet not found -> $snippet"
                    continue
                fi

                if [[ "$col" -eq 0 ]]; then
                    # insert head
                    cat "$snippet_path" "$target" > "$target.tmp" && mv "$target.tmp" "$target"
                else
                    # insert specified line
                    sed -i "${col}r $snippet_path" "$target"
                fi

                echo "Inserted $snippet into $target at line $col"
            done

            echo "✅ Multiple snippets inserted successfully."
            return 0
            ;;   
        -d|--delete)
            if [[ $# -lt 2 ]]; then
                echo "Please specify the snippet name to delete."
                return 1
            fi
            snippet_name="$2"
            snippet_path="$HOME/.utilc/snippets/${snippet_name}.txt"
            if [[ -f "$snippet_path" ]]; then
                rm "$snippet_path"
                echo "Deleted snippet: $snippet_name"
            else
                echo "Snippet not found: $snippet_name"
                return 1
            fi
            return 0
            ;;
        -f|--find)
            if [[ $# -lt 2 ]]; then
                echo "Please specify the keyword to search."
                return 1
            fi
            keyword="$2"
            for f in "$HOME/.utilc/snippets/"*.txt; do
                fname=$(basename "$f" .txt)
                if [[ "$fname" == *"$keyword"* ]]; then
                    echo "$fname"
                fi
            done
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
        # insert head
        cat "$snippet_path" "$target" > "$target.tmp" && mv "$target.tmp" "$target"
    else
        # insert specified line
        sed -i "${col}r $snippet_path" "$target"
    fi

    echo "Inserted $snippet into $target at line $col"
}

fttest() {
    local cmd
    local keep_flag=0
    local tests=()

    # コマンドライン解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--insert)
                cmd="insert"
                shift
                ;;
            -r|--run)
                cmd="run"
                shift
                ;;
            -k|--keep)
                keep_flag=1
                shift
                ;;
            -h|--help)

                cat ~/.utilc/.man/fttest.txt
                return 0
                ;;
            init)
                echo "Initializing standard test templates..."
                mkdir -p ~/.utilc/.tests
                # 例: limit_test.tmp
                [[ ! -f ~/.utilc/.tests/limit_test.tmp ]] && cat > ~/.utilc/.tests/limit_test.tmp <<'EOF'
printf("[limit_test: INT_MAX] => %d\n", {placeholder}(INT_MAX));
printf("[limit_test: INT_MIN] => %d\n", {placeholder}(INT_MIN));
EOF
                [[ ! -f ~/.utilc/.tests/null_test.tmp ]] && cat > ~/.utilc/.tests/null_test.tmp <<'EOF'
printf("[null_test] => %d\n", {placeholder}(NULL));
EOF
                echo "Templates generated in ~/.utilc/.tests/"
                return 0
                ;;
            *)
                break
                ;;
        esac
    done

    # 処理確認
    if [[ -z "$cmd" ]]; then
        echo "No command specified. Use -h for help."
        return 1
    fi

    echo "Command: $cmd"
    echo "Keep flag: $keep_flag"
    echo "Tests: ${tests[*]}"

    # insert mode
    if [[ "$cmd" == "insert" ]]; then
        local target_func="$1"
        shift
        local tests=("$@")

        local src_file="${target_func}.c"
        local target_file
        target_file=$(find . -maxdepth 1 -name "*.main.c" | head -n 1)

        if [[ ! -f "$src_file" ]]; then
            echo "Error: source file '$src_file' not found."
            return 1
        fi
        if [[ -z "$target_file" ]]; then
            echo "Error: no .main.c file found in current directory."
            return 1
        fi

        echo "Target function: $target_func"
        echo "Source: $src_file"
        echo "Target main: $target_file"
        echo "Tests: ${tests[*]}"

        # === 1. プロトタイプ抽出 ===
        local func_header
        func_header=$(grep -E "^[a-zA-Z_][a-zA-Z0-9_[:space:]\*]*[[:space:]]+$target_func[[:space:]]*\(.*\)" "$src_file" \
            | head -n 1 | sed 's/[[:space:]]*{[[:space:]]*$//')

        if [[ -z "$func_header" ]]; then
            echo "Error: Function '$target_func' not found in $src_file"
            return 1
        fi

        # === 2. プロトタイプ挿入 ===
        local include_last proto_line
        include_last=$(grep -n '^#include' "$target_file" | tail -n 1 | cut -d: -f1)
        proto_line=$((include_last + 2))

        if grep -q "$target_func" "$target_file"; then
            echo "Prototype already exists for $target_func (skipped)"
        else
            sed "${proto_line}i /* prototype for test */\n${func_header};" "$target_file" > "$target_file.tmp"
            mv "$target_file.tmp" "$target_file"
            echo "Inserted prototype for '$target_func' at line $proto_line"
        fi

        # === 3. テスト挿入 ===
        local insert_line
        insert_line=$(grep -n 'return *(0)' "$target_file" | tail -n 1 | cut -d: -f1)
        insert_line=$((insert_line - 2))

        for test in "${tests[@]}"; do
            local test_file="$HOME/.utilc/.tests/${test}.tmp"
            if [[ -f "$test_file" ]]; then
                # placeholder を対象関数名に置換して挿入
                sed "s/{placeholder}/$target_func/g" "$test_file" | \
                    sed "${insert_line}r /dev/stdin" "$target_file" > "$target_file.tmp"
                mv "$target_file.tmp" "$target_file"
                echo "Inserted test '$test' into main"
            else
                echo "Warning: test template '${test}.tmp' not found"
            fi
        done

        echo "✅ Insert complete."
        return 0
    fi

    # run mode
    if [[ "$cmd" == "run" ]]; then
        if [[ ${#tests[@]} -eq 0 ]]; then
            echo "No tests specified for run."
            return 1
        fi

        local target_file=".main.c"
        if [[ ! -f "$target_file" ]]; then
            echo "$target_file not found! Create or generate it first."
            return 1
        fi

        local ft_file="_fttest_.c"
        > "$ft_file"

        # 1. 共通ヘッダ挿入
        echo '#include "~/.utilc/util.h"' >> "$ft_file"

        # 2. 対象Cファイルリンク
        echo "#include \"$target_file\"" >> "$ft_file"

        # 3. 関数宣言抽出
        grep -E '^[a-zA-Z_][a-zA-Z0-9_]* [a-zA-Z_][a-zA-Z0-9_]*\s*\(.*\)' "$target_file" | \
            awk '{print $1, $2}' | sed 's/$/;/' >> "$ft_file"

        # 4. main関数にテストコードを挿入
        echo "int main(void) {" >> "$ft_file"
        for test in "${tests[@]}"; do
            local tmp_path="$HOME/.utilc/.tests/${test}.tmp"
            if [[ ! -f "$tmp_path" ]]; then
                echo "Test template not found: $tmp_path"
                continue
            fi
            # placeholder を関数名に置換
            local func_name
            func_name=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_]* [a-zA-Z_][a-zA-Z0-9_]*\s*\(.*\)' "$target_file" | head -n1 | awk '{print $2}' | sed 's/(.*//')
            sed "s/{placeholder}/$func_name/g" "$tmp_path" >> "$ft_file"
        done
        echo "return 0;" >> "$ft_file"
        echo "}" >> "$ft_file"

        # 5. valgcでコンパイル＆実行
        valgc "$ft_file"

        # 6. クリーンアップ
        if [[ $keep_flag -eq 0 ]]; then
            rm -f "$ft_file" _fttest_
        else
            echo "Keep flag set: $ft_file and binary retained."
        fi

        return 0
    fi

}
