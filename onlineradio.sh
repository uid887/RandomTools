#!/bin/bash
# File:        onlineradio.sh
# Author:      Christo Deale 
# Date:        2025-07-08
# Version:     1.0.0
# Description: Displays a menu of online radio stations and plays the selected station using mpv.

echo "Pick a station:"
echo "1. Algoa FM - PE"
echo "2. Bok Radio - Brackenfell"
echo "3. Groot FM - Pretoria"
echo "4. KFM - Kaapstad"
echo "5. Jacaranda - Pretoria"
echo "6. OFM - Bloemfontein"
echo "7. Radio Orania - Orania"
echo "8. Radio Fynbox - Stilbaai"
echo "9  Radio Roepsein - Upington"
echo "10. Alex Jones - InfoWars"
echo "11. BBC World Service"
echo "12. Capital FM London"
echo "13. Heart London"
echo "14. SkyNews Radio UK"
echo "15. Houston Blues - US"
echo "16. Rense - US"
echo "17. WABC 770 AM - US"
echo "18. CFOX 99.3 - VanCity"
echo "19. SportsNet 360 Vancouver"
echo "20. CKNG-FM The Chuck 92.5 Edmonton"
echo "21. CKNW Vancouver"

read -p "Enter number: " choice

case $choice in
  1) mpv --quiet https://edge.iono.fm/xice/54_high.aac ;;
  2) mpv --quiet https://bokradio.highquality.radiostream.co.za/ ;;
  3) mpv --quiet https://edge.iono.fm/xice/330_high.aac ;;
  4) mpv --quiet https://playerservices.streamtheworld.com/api/livestream-redirect/KFM.mp3 ;;
  5) mpv --quiet https://live.jacarandafm.com/jacarandahigh.mp3 ;;
  6) mpv --quiet https://edge.iono.fm/xice/ofm_live_high.aac;;
  7) mpv --quiet https://saukradio.com/wp-content/uploads/2021/07/5-Julie-Orania.mp3 ;;
  8) mpv --quiet https://stream-152.zeno.fm/w0cyqt4cyy8uv?zs=KrkViuxOTr6gZl4perU1jA ;;
  9) mpv --quiet https://fm1.cvdrbroadcastsolutions.com:8443/radio_roepsein.aac ;;
 10) mpv --quiet http://173.226.180.143/alexjonesshow-mp3 ;;
 11) mpv --quiet http://stream.live.vc.bbcmedia.co.uk/bbc_world_service ;;
 12) mpv --quiet http://media-ice.musicradio.com/CapitalMP3 ;;
 13) mpv --quiet https://ice-sov.musicradio.com/HeartLondonMP3 ;;
 14) mpv --quiet https://video.news.sky.com/snr/news/snrnews.mp3 ;;
 15) mpv --quiet http://edge3.peta.live365.net/b76353_128mp3 ;;
 16) mpv --quiet http://s9.voscast.com:9310/live ;;
 17) mpv --quiet https://playerservices.streamtheworld.com/api/livestream-redirect/WABCAM.mp3 ;;
 18) mpv --quiet https://live.leanstream.co/CFOXFM-MP3 ;;
 19) mpv --quiet https://rogers-hls.leanstream.co/rogers/van650.stream/icy ;;
 20) mpv --quiet https://corus.leanstream.co/CKNGFM-MP3 ;;
 21) mpv --quiet https://live.leanstream.co/CKNWAM ;; 
*) echo "Invalid choice!" ;;
esac
