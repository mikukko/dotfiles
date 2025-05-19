# remove local dotfiles
rm -f ~/.zshrc ~/.zprofile ~/.vimrc ~/.gitconfig ~/.gitignore

# use git dotfiles
ln -s .zshrc ~/.zshrc
ln -s .zprofile ~/.zprofile
ln -s .vimrc ~/.vimrc
ln -s .gitconfig ~/.gitconfig
ln -s .gitignore ~/.gitignore

# ln iCloud
ln -s /Users/miku/Library/Mobile\ Documents/com~apple~CloudDocs ~/iCloud