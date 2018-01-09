# install mardown-vim

* install pathogen.vim
wget https://github.com/tpope/vim-pathogen/archive/master.zip
unzip vim-pathogen
cp autoload/pathogen.vim ~/.vim/autoload/
vim ~/.vimrc

```bash
execute pathogen#infect()
syntax on
filetype plugin indent on
let g:vim_markdown_folding_style_pythonic = 1
set foldenable
```

* 是哪个用户就在哪个目录下修改.vimrc 或者把文件放到相应位置 .vim/ 
