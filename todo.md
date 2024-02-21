creare una roba tipo spotlight per ricercare diretamente su firefox
#spotlight
#bindsym \$mod+space exec 'dmenu -nf "#F8F8F2" -nb "#282A36" -sb "#6272A4" -sf "#F8F8F2" -fn "JetBrainsMonoNerdFontPropo-Thin-10" -p "Search:" | tr ' ' '+' | firefox https://www.google.com/search?client=firefox-b-d&q='
#nf color foregroun
#nb color background
#sb selecte background color
#dmenu -nf "#F8F8F2" -nb "#282A36" -sb "#6272A4" -sf "#F8F8F2" -fn "JetBrainsMonoNerdFontPropo-Thin-10" -p "Search:" | firefox https://www.google.com/search?client=firefox-b-d&q= #TODO: risultato di dmenu con spazzi sostituiti da +
