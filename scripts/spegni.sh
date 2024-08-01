ask_confirmation_nvim() {
	read -p "$1 (y/N): " response
	case "$response" in
	[yY])
		shutdown -h now
		return 0 # Conferma
		;;
	*)
		return 1 # Non conferma
		;;
	esac
}
if ask_confirmation "Confermi di spegnere il computer?"; then
	echo "Fatto! / Done!"
else
    echo "Non hai confermato. / Not Done !"
fi
