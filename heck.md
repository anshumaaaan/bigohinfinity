<h1 align="center" id="title">Chess Vision</h1>

<p align="center"><img src="https://i.ibb.co/xgxQNw2/icons8-chess-32.png" alt="project-image"></p>

<p id="description">This repository contains code for a computer vision-based system designed to analyze chess games played offline. Traditional offline chess games lack the automated analysis capabilities of online games due to the absence of digital records of moves. To bridge this gap we introduce a novel approach utilizing computer vision to detect and analyze chessboard positions enabling comprehensive move-by-move analytics.</p>

<h2>Project Screenshots:</h2>

<img src="https://i.postimg.cc/MKgQd94z/chess-app-ui.png" alt="project-screenshot">

<img src="https://i.postimg.cc/6QXGNytS/qw8580cw.png" alt="project-screenshot">

<img src="https://i.postimg.cc/Z53ygrtp/Whats-App-Image-2024-03-10-at-10-04-24.jpg" alt="project-screenshot">

  
  
<h2>🧐 Overview</h2>

Here're some of the project's best features:

*   Accurate Piece Detection
*   Board Detection
*   Moves Analysis
*   Online Friends
*   Live Match Analysis
*   Get hits and suggestion

## 💻Key Features
-Chessboard Detection: Utilizing computer vision techniques, our system accurately identifies the chessboard and individual pieces from images or video frames.

-Move Tracking: Once the chessboard is detected, our system tracks changes in piece positions, recording each move made during the game.

-Data Processing: The recorded moves are processed and converted into a format suitable for analysis, providing a detailed timeline of the game's progression.

-Integration with Stockfish: The processed data is fed into Stockfish, a powerful open-source chess engine, for comprehensive game analysis and evaluation of strategic moves.
  
  ## 🛠️How It Works

-Chessboard Detection: The input image or video frame is processed using computer vision algorithms to identify the chessboard and piece positions.

-Move Tracking: Changes in the chessboard configuration are continuously monitored, and each move made during the game is recorded.

-Data Processing: Recorded moves are processed to generate a chronological sequence of chessboard configurations, forming a complete game history.

-Stockfish Integration: The game history data is input into Stockfish, which performs in-depth analysis, evaluating the quality of each move and providing strategic insights.

<img src="https://miro.medium.com/v2/resize:fit:1400/1*wKITWi9maBvBSpouXAJwFQ.png" alt="project-screenshot">

<h2>💻 Built with</h2>

Technologies used in the project:

*   Flutter
*   Yolov5
*   Dart
*   OpenCV
*   Tensorflow
*   Firebase