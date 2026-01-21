# Productivity Chess Timer

A minimalist macOS SwiftUI application inspired by a **chess clock** concept, designed to help you stay focused on a single task while objectively tracking time lost to distractions.

Instead of pausing a timer when you get distracted, you **switch sides**—just like in chess.

---

## Concept

* **Work time** counts down toward a predefined goal.
* **Distraction time** counts up whenever you lose focus.
* Switching between them is manual and intentional.

This makes distractions visible and measurable, encouraging better focus habits.

---

## Features

* ⏱️ Adjustable task duration (setup mode)
* ♟️ Chess-clock–style switching between *Work* and *Distractions*
* 📊 Separate tracking of productive time and distraction time
* 🪟 Floating, always-on-top window
* 🧼 Minimalist UI with fixed window size

---

## How It Works

1. Set how long your task should take.
2. Start the session.
3. Click **YOUR TASK** to start working.
4. When distracted, click **DISTRACTIONS**.
5. Switch back when you refocus.
6. The session ends when work time reaches zero.

---

## Tech Stack

* **Language:** Swift
* **Framework:** SwiftUI
* **Platform:** macOS
* **Architecture:** MVVM (`TimerViewModel`)

---

## Requirements

* macOS
* Xcode (with SwiftUI support)

---

## Build & Run

1. Open the project in **Xcode**.
2. Select a macOS target.
3. Build and run (`Cmd + R`).

The app launches as a small floating window that stays above other apps.

---

## Motivation

Traditional Pomodoro timers hide distractions by pausing time.

This app does the opposite: it **exposes distractions** by measuring them.

Awareness leads to better focus.

---

## Future Ideas

* Session history & statistics
* Sound or haptic feedback
* Auto-detection of inactivity
* Custom themes

---

## License

This project is intended for educational and personal productivity use. 
