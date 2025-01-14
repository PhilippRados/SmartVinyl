# SmartVinyl 💿
### A music app to control your record player. <br>
The music player connects to Discogs' public API to fetch various record information. Then you can select any song from your records and have the needle on your record player move to the correct position to play the song. It can also start/stop any song by lifting the needle. It does this by using servos that connect with wires to the record player's arm. 

## Flow chart
This shows how the app communicates with the Discogs API. The added albums are serialized for the next use. Then whenever a song in an album is picked. The correct servo rotation is calculated by the index of the song in the record and the length of the previous songs. This information is then sent to the ESP32
which acts as a local server. When the servos finished their movement it is reported back to the app and the user can continue with his next actions.

<img width="600" alt="sketch" src="https://github.com/user-attachments/assets/03953757-7edb-4c95-b77f-a48dca95dabc" />



## Esp32 servo setup
The wires connected to the servo move the arm.<br>

<img width="448" alt="servos" src="https://github.com/user-attachments/assets/b80881eb-c1ce-4e8b-a5b0-e3eab4772312" />


## Notice
I thought I was finished with this project until I realized that every record has different lengths which are determined by the different groove-distances. I assumed that that would be standardized which would allow me to infer the record-player-position just by the song-lengths. Now I have to come up with a different way to find the correct positions on any record.
