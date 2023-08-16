# ACSP Exam Prep

**ACSP Exam Prep** is a Swift-based application aimed to assist users in preparing for the Apple Certified Support Professional examination. The app presents questions and answers in both a study mode and an exam mode, allowing users to gauge their knowledge and readiness for the examination.

![ACSP Exam Prep Logo](https://github.com/CraigOpie/acsp/blob/main/ACSP%20Exam%20Prep/ACSP%20Exam%20Prep/Icon/iPhone/AppIcon.appiconset/180.png?raw=true)

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Source Code Overview](#source-code-overview)
- [License](#license)
- [Contact](#contact)

## Features

- **Study Mode**: Users can review questions with instant feedback to ensure they understand the correct answers.
- **Exam Mode**: Simulates the actual examination environment, providing users with a set of questions to answer without instant feedback.
- **Intuitive UI**: A simple and clean user interface with progress tracking.

## Installation

To install and run the app:

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Build and run the app on the desired simulator or a physical device.

## Usage

1. Launch the app.
2. Choose either "Study Mode" or "Exam Mode".
3. Answer questions. In study mode, instant feedback is provided after each question.
4. At the end of the set, a performance breakdown is displayed.

## Source Code Overview

- `Question.swift`: This is the main model for the questions and answers. It supports both single and multiple correct answers and is built to decode from JSON structures.
  
  - `isCorrectAnswer(_:)`: A method to check if the given answer(s) is/are correct.

- `ContentView.swift`: This is the primary view of the application. It handles both the menu for selecting the mode and the main quiz interface.

  - `QuizMode`: An enum representing the two modes of the quiz - study and exam.
  - `loadQuestions()`: A method to load questions from a JSON file.
  - `checkAnswer()`: Checks the correctness of a user's answer in study mode.
  - `moveToNextQuestion()`: Progresses to the next question or displays results if the quiz is finished.
  - `retryQuiz()`: Resets the quiz so users can attempt it again.
  - `ProgressBar`: A custom SwiftUI view to represent the progress through the quiz questions.

## License

This software is licensed under a custom license. The source code can be downloaded and built for personal use, but any derivatives or duplications are prohibited, and no one else has the rights to sell or distribute this work. For full license terms, see [LICENSE.md](https://github.com/CraigOpie/acsp/blob/main/LICENSE.md).

## Contact

If you have any questions, suggestions, or feedback, feel free to open an issue or pull request.
