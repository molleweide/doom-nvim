# getting `norg` to build again

```vim
nvim-treesitter[yaml]: Error during compilation
gcc-11: warning: could not understand version 13.01.00
In file included from /usr/local/Cellar/gcc/11.3.0_1/lib/gcc/11/gcc/x86_64-apple-darwin20/11/include/stdint.h:9,
                 from ./src/tree_sitter/parser.h:9,
                 from src/parser.c:1:
/usr/local/Cellar/gcc/11.3.0_1/lib/gcc/11/gcc/x86_64-apple-darwin20/11/include-fixed/stdint.h:27:10:
fatal error: sys/_types/_int8_t.h: No such file or directory
   27 | #include <sys/_types/_int8_t.h>
      |          ^~~~~~~~~~~~~~~~~~~~~~
compilation terminated.
In file included from /usr/local/Cellar/gcc/11.3.0_1/lib/gcc/11/gcc/x86_64-apple-darwin20/11/include/stdint.h:9,
                 from ./src/tree_sitter/parser.h:9,
                 from src/scanner.cc:1:
/usr/local/Cellar/gcc/11.3.0_1/lib/gcc/11/gcc/x86_64-apple-darwin20/11/include-fixed/stdint.h:27:10:
fatal error: sys/_types/_int8_t.h: No such file or directory
   27 | #include <sys/_types/_int8_t.h>
      |          ^~~~~~~~~~~~~~~~~~~~~~
compilation terminated.
```

but if we talk about artificial intelligence since it is about how you can work
with other stategies. you are the previous digitalization minister and so the
question is how would that do something for the shit that they could ever
fucking do

After having installed `gcc-12` and ran switched xcode CLI tools to `/Library/Developer/CommandLineTools/`

```vim
nvim-treesitter[norg_meta]: Could not create tree-sitter-norg_meta-tmp
mkdir: tree-sitter-norg_meta-tmp: File exists
nvim-treesitter[norg_table]: Could not create tree-sitter-norg_table-tmp
mkdir: tree-sitter-norg_table-tmp: File exists
[nvim-treesitter] [5/9, failed: 3] Creating temporary directory
[nvim-treesitter] [5/9, failed: 3] Creating temporary directory
[nvim-treesitter] [5/9, failed: 3] Extracting tree-sitter-norg...
nvim-treesitter[norg]: Could not create tree-sitter-norg-tmp
mkdir: tree-sitter-norg-tmp: File exists
[nvim-treesitter] [6/9, failed: 4] Compiling...
[nvim-treesitter] [6/9, failed: 4] Compiling...
[nvim-treesitter] [7/9, failed: 4] Treesitter parser for norg_table has been installed
[nvim-treesitter] [7/9, failed: 4] Compiling...
[nvim-treesitter] [8/9, failed: 4] Treesitter parser for norg_meta has been installed
nvim-treesitter[norg]: Error during compilation
src/scanner.cc:162:35: error: expected expression
    return std::vector<TokenType>({lhs, static_cast<TokenType>(rhs)});
                                  ^
src/scanner.cc:165:23: warning: rvalue references are a C++11 extension [-Wc++11-extensions]
std::vector<TokenType>&& operator|(std::vector<TokenType>&& lhs, TokenType rhs)
                      ^
src/scanner.cc:165:58: warning: rvalue references are a C++11 extension [-Wc++11-extensions]
std::vector<TokenType>&& operator|(std::vector<TokenType>&& lhs, TokenType rhs)
                                                         ^
src/scanner.cc:177:10: warning: 'auto' type specifier is a C++11 extension [-Wc++11-extensions]

```

## after having made sure I am using gcc-12

The following are messages related to neorg:

After starting vim I run `TSInstall norg`

```vim
[nvim-treesitter] [0/1] Downloading tree-sitter-norg...
[nvim-treesitter] [0/1] Creating temporary directory
[nvim-treesitter] [0/1] Extracting tree-sitter-norg...
[nvim-treesitter] [0/1] Compiling...
[nvim-treesitter] [1/1] Treesitter parser for norg has been installed
```

Then I enter an `index.norg` file:

```vim
[nvim-treesitter] [2/5] Downloading tree-sitter-norg...
[nvim-treesitter] [2/5] Downloading tree-sitter-norg_meta...
[nvim-treesitter] [2/5] Downloading tree-sitter-norg_table...
[nvim-treesitter] [2/5] Creating temporary directory
[nvim-treesitter] [2/5] Extracting tree-sitter-norg...
[nvim-treesitter] [2/5] Creating temporary directory
[nvim-treesitter] [2/5] Extracting tree-sitter-norg_table...
[nvim-treesitter] [2/5] Creating temporary directory
[nvim-treesitter] [2/5] Extracting tree-sitter-norg_meta...
[nvim-treesitter] [2/5] Compiling...
[nvim-treesitter] [2/5] Compiling...
[nvim-treesitter] [2/5] Compiling...
[nvim-treesitter] [3/5] Treesitter parser for norg_table has been installed
[nvim-treesitter] [4/5] Treesitter parser for norg_meta has been installed
[nvim-treesitter] [5/5] Treesitter parser for norg has been installed

```

I switch to another NON-NORG file and then switch back to norg `index.norg`.
Then I get these messages:

```vim
"index.norg" 323L, 10058B
[nvim-treesitter] [5/11] Downloading tree-sitter-norg...
[nvim-treesitter] [5/11] Downloading tree-sitter-norg_meta...
[nvim-treesitter] [5/11] Downloading tree-sitter-norg_table...
[nvim-treesitter] [5/11] Downloading tree-sitter-norg...
[nvim-treesitter] [5/11] Downloading tree-sitter-norg_meta...
[nvim-treesitter] [5/11] Downloading tree-sitter-norg_table...
[nvim-treesitter] [5/11] Creating temporary directory
[nvim-treesitter] [5/11] Creating temporary directory
[nvim-treesitter] [5/11] Extracting tree-sitter-norg_table...
[nvim-treesitter] [5/11] Extracting tree-sitter-norg_meta...
[nvim-treesitter] [5/11] Creating temporary directory
nvim-treesitter[norg_meta]: Could not create tree-sitter-norg_meta-tmp
mkdir: tree-sitter-norg_meta-tmp: File exists
[nvim-treesitter] [6/11, failed: 1] Creating temporary directory
[nvim-treesitter] [6/11, failed: 1] Creating temporary directory
[nvim-treesitter] [6/11, failed: 1] Creating temporary directory
nvim-treesitter[norg_table]: Could not create tree-sitter-norg_table-tmp
mkdir: tree-sitter-norg_table-tmp: File exists
[nvim-treesitter] [7/11, failed: 2] Extracting tree-sitter-norg...
nvim-treesitter[norg]: Could not create tree-sitter-norg-tmp
mkdir: tree-sitter-norg-tmp: File exists
[nvim-treesitter] [8/11, failed: 3] Compiling...
[nvim-treesitter] [8/11, failed: 3] Compiling...
[nvim-treesitter] [9/11, failed: 3] Treesitter parser for norg_table has been installed
[nvim-treesitter] [9/11, failed: 3] Compiling...
[nvim-treesitter] [10/11, failed: 3] Treesitter parser for norg_meta has been installed
[nvim-treesitter] [11/11, failed: 3] Treesitter parser for norg has been installed
```

every time I switch back to the norg file the `[nvim-treesitter] [xx/yy, ...]`
xx and yy numbers get increasingly larger it seems.

## additional message to #246

For anyone reading, make sure to update brew to latest version with `brew
upgrade` in order to be able to install `gcc-12`. I had updated to macOS 13
`Ventura` and one of my issues was not realising that I had to upgrade `brew`.

Another issue for me was that using `CC=/usr/local/Cellar/<path-to-gcc-12>` did
not work, BUT using only `alias vc="CC=gcc-12 <path-to-nvim>` did work ????
