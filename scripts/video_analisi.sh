#!/bin/bash
echo "url video? "
read URL_VIDEO
cd $HOME/.config/fabric
yt --transcript $URL_VIDEO >transcvideo.txt
echo -e "\n===== ESTRAZIONE DI SAGGEZZA ====="
cat transcvideo.txt | fabric -sp extract_wisdom
# echo -e "\n===== RIASSUNTO ====="; cat transcvideo.txt | fabric -sp summarize;
# echo -e "\n===== ANALISI AFFERMAZIONI ====="; cat transcvideo.txt | fabric -sp analyze_claims;
echo -e "\n===== VALUTAZIONE CONTENUTO ====="
cat transcvideo.txt | fabric -sp rate_content
#| fabric -sp rate_content;
echo -e "\n"
