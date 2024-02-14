###### Install Package First ######

### TO TEST !!! ###


ask_confirmation() {
    read -p "$1 (y/n): " response
    case "$response" in
        [yY])
            return 0 # Conferma
            ;;
        *)
            return 1 # Non conferma
            ;;
    esac
}

echo "Hai già installato tutti i pacchetti?"
if ask_confirmation "Confermi?"; then
    ln -sf ~/git/DotFiles/bashrc/daily.sh ~/.bashrc
    ln -sf ~/git/DotFiles/* ~/
else
    echo "Non hai confermato."
fi





