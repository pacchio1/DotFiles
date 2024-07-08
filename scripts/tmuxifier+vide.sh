#!/bin/bash
gclone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier

touch /home/mark/.tmuxifier/layouts/vide.session.sh
echo "session_root '~/git'" > /home/mark/.tmuxifier/layouts/vide.session.sh
echo "" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "if initialize_session 'vide'; then" > /home/mark/.tmuxifier/layouts/vide.session.sh
echo "  new_window 'nvim'" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "  run_cmd 'nvim'" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "  new_window 'lazygit'" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "  run_cmd 'lazygit'" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "  new_window 'term'" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "  run_cmd 'gitf'" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "  split_v 50" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "fi" >> /home/mark/.tmuxifier/layouts/vide.session.sh
echo "finalize_and_go_to_session" >> /home/mark/.tmuxifier/layouts/vide.session.sh
