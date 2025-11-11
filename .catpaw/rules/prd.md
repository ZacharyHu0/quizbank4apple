---
ruleType: Optional types are Always, Auto Attached, Manual, and Model Request
description: Description of the rules
globs: Only needed in Auto Attached mode, specify the file extensions to match, such as *.vue,*.ts
---

### **Product Requirements Document (PRD)**

**App Name**: Quiz Challenge
**Platform**: macOS (Support for macOS 26 Liquid Glass UI)
**App Version**: 1.0
**Development Environment**: Cursor IDE
**Code Base**: SwiftUI for UI, Core Data for persistent storage, CSV parsing for the quiz database
**App Type**: Educational/Quiz Application
**Status**: Prototype
**Target Audience**: Students, individuals looking to prepare for quizzes or practice knowledge

---

### **1. App Overview**

Quiz Challenge is an educational app that lets users practice and test their knowledge with interactive quizzes. The app is built to resemble native Apple applications in terms of design, providing a smooth, clean interface with fluid, intuitive controls. The app will support the macOS Liquid Glass style and dark/light theme transitions. It supports CSV-based databases for question sets and maintains user challenge progress.

---

### **2. Key Features**

1. **Main Page (Home Screen)**:

   * **Buttons**:

     * **"继续挑战"** ("Continue Challenge") – Visible if there’s a previous challenge record, otherwise hidden.
     * **"新挑战"** ("New Challenge") – Starts a new quiz challenge, user chooses a quiz database.
     * **"选择题库"** ("Choose Question Bank") – Allows users to pick a specific quiz bank.
     * **"查看错题"** ("Review Mistakes") – Shows incorrect answers and allows for review.
     * **"历史统计"** ("Historical Statistics") – Displays quiz statistics like average time per question.
   * **Settings (Top Right)**:

     * **Theme Switcher**:

       * "Bright" (light mode)
       * "Dark" (dark mode)
       * "Follow System" (follows macOS system theme)
2. **Challenge Page**:

   * Displays the quiz with a title bar showing the current question bank.
   * Shows the current question with selectable answers.
   * **Navigation Buttons**:

     * **上一题** ("Previous Question") – Navigate to the previous question.
     * **"不知道"** ("I Don’t Know") – Marks the answer as incorrect.
     * **下一题** ("Next Question") – Navigate to the next question.
   * **Progress Indicator**:

     * A series of colored small rectangles (representing the questions).
     * **Color Codes**:

       * Red for incorrect answers.
       * Green for correct answers.
       * Gray for unanswered questions.
     * **Statistics** (e.g., 10/12 50.0%) showing the number of answered and unanswered questions with the correct answer rate.
3. **Review Mistakes Page**:

   * Displays questions that were answered incorrectly.
   * Option to filter/sort by error frequency or recent mistakes.
   * Each question displayed as a card that can be expanded to show the full question and answer options.
4. **Historical Statistics Page**:

   * Displays a summary of the user’s performance over time.
   * Shows metrics like:

     * Total questions attempted.
     * Average time per question.
     * Correct answer percentage.
   * Displays a **Reset Data** button that clears all data.
   * Uses interactive graphs similar to Apple’s "Screen Time" feature in iOS Settings.

---

### **3. UI/UX Design**

#### **Design Style**

* **Overall UI**: Clean, minimalistic, and fluid, with an emphasis on simplicity and functionality. The design should mimic Apple's native applications, with rounded corners and subtle animations.
* **Liquid Glass Effect**: Implemented on buttons and overlays to create a sleek, frosted glass effect. This will adjust based on the current system theme (light/dark).
* **Light/Dark Mode**: The app’s interface should adapt to the system’s current mode (light/dark) with appropriate color schemes for readability.

#### **Buttons and Controls**

* **Main Buttons**: Semi-transparent, rounded, with subtle Liquid Glass effect on hover or click.
* **Answer Options**: Buttons that highlight in green or red when selected. Non-interactive options are visually distinct.
* **Progress Bar**: Small round progress dots in the quiz view, showing color-coded progress.

---

### **4. Data Structure**

The quiz data will be stored in CSV files, each representing a question bank. The CSV files should follow this structure:

* **CSV Columns**:

  1. **题号** ("Question ID")
  2. **年份** ("Year")
  3. **模块** ("Module")
  4. **周** ("Week")
  5. **题干** ("Question Text")
  6. **选项** ("Options") – Comma-separated list of answer choices.
  7. **答案** ("Answer") – The correct answer, corresponding to one of the options.

Example CSV filename: `M5_week3.csv`

#### **Example CSV Data**:

| 题号 | 年份   | 模块 | 周 | 题干           | 选项                 | 答案 |
| -- | ---- | -- | - | ------------ | ------------------ | -- |
| 1  | 23 | 5 | 3 | What is 2+2? | "A.2", "B.4", "C.6", "D.8" | "B.4"  |
| 2  | 23 | 5 | 3 | What is 5+3? | "A.5", "B.6", "C.7", "D.8" | "D.8"  |

---

### **5. Functional Flow**

#### **1. Starting a New Challenge**

1. User clicks **“新挑战”**.
2. User selects a question bank.
3. A new challenge is started, and the quiz page opens with the first question.
4. The system records the user’s responses and updates their progress.

#### **2. Continuing an Existing Challenge**

1. User clicks **“继续挑战”**.
2. The app reads the previous challenge data from local storage.
3. The last saved challenge page is opened, showing the last answered questions and the progress.

#### **3. Reviewing Mistakes**

1. User clicks **“查看错题”**.
2. The app loads a list of incorrectly answered questions.
3. The user can sort by “Error Frequency” or “Newest Errors”.
4. Clicking on a question expands it to show the full text and options.

#### **4. Viewing Historical Statistics**

1. User clicks **“历史统计”**.
2. The app presents graphs of quiz performance (e.g., total correct answers, average time per question).
3. Option to reset data using the **Reset Data** button.

---

### **6. Technical Requirements**

* **Database Format**: CSV files for quiz data.
* **Persistent Storage**: Core Data for saving user progress, including challenge history and stats.
* **UI Framework**: SwiftUI (for the macOS Liquid Glass UI and fluid interactions).
* **Data Parsing**: Use `CSV.swift` or custom CSV parsing code to load and parse the question bank CSV files.

---

### **7. Folder Structure (for Cursor IDE)**

```plaintext
QuizChallenge/
├── Assets/
│   ├── Images/         # App icons and images
│   ├── Themes/         # Light/Dark theme assets
│   └── LiquidGlass/    # UI Liquid Glass components (views, buttons)
├── Data/
│   ├── M5_week1.csv    # Example question bank CSV files
│   ├── M5_week2.csv
│   └── M5_week3.csv
├── Models/
│   ├── Challenge.swift   # Model for quiz challenges
│   └── UserStats.swift   # Model for user statistics
├── Views/
│   ├── HomeView.swift    # Main screen UI
│   ├── ChallengeView.swift # Quiz challenge page
│   ├── ReviewMistakesView.swift # Mistake review page
│   └── StatsView.swift   # Historical statistics view
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── ChallengeViewModel.swift
│   └── StatsViewModel.swift
└── Resources/
    └── Localization/      # Localization files if needed
```

---

### **8. Next Steps**

1. Design and implement the main UI components (buttons, progress indicators).
2. Implement quiz data parsing from CSV files.
3. Develop Core Data model for storing user progress.
4. Implement quiz logic (next question, previous question, checking answers).
5. Add historical statistics and mistake review functionality.
6. Test app for usability and fluid interaction with Liquid Glass UI effects.

---

