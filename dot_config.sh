# remove local dotfiles
rm -f ~/.zshrc ~/.zprofile ~/.vimrc ~/.gitconfig ~/.gitignore

# use git dotfiles
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.zprofile ~/.zprofile
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.gitignore ~/.gitignore


