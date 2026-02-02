<div align="center">

# Todo App in Swift

A native macOS/iOS application built entirely with **SwiftUI** and **CoreData**. Subtasks, drag-and-drop, customizable themes, particle animations and sound/haptic feedback — all without any third-party dependencies.

![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=for-the-badge&logo=apple&logoColor=white)
![CoreData](https://img.shields.io/badge/CoreData-34C759?style=for-the-badge&logo=apple&logoColor=white)
![macOS](https://img.shields.io/badge/macOS%2014+-FF9500?style=for-the-badge&logo=apple&logoColor=white)
![iOS](https://img.shields.io/badge/iOS%2017+-AF52DE?style=for-the-badge&logo=apple&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-FFD60A?style=for-the-badge)

</div>

> **[Lire en Francais](README.fr.md)**

---

## Features

```
+---------------------------------------------+
|             Todo App                  [gear]|
+---------------------------------------------+
|  [ Enter a new task...          ] [+ Add]   |
+---------------------------------------------+
|  Active: 3       Done: 5       Total: 8     |
+---------------------------------------------+
|  [All]  [Active]  [Completed]               |
+---------------------------------------------+
|                                             |
|  [x] Buy groceries              [edit][del] |
|      |-- [x] Milk                           |
|      |-- [ ] Eggs                           |
|      |-- [x] Bread                          |
|      Progress: =========>       66%         |
|                                             |
|  [ ] Finish the project         [edit][del] |
|      |-- [ ] Write tests                    |
|      |-- [ ] Fix bugs                       |
|      Progress: =>               0%          |
|                                             |
|  [x] Clean the house            [edit][del] |
|                                             |
+---------------------------------------------+
```

### Task Management
- Create, edit and delete tasks
- Mark tasks as completed with an animated checkbox toggle
- Drag-and-drop reordering with persistent sort order
- Filter tasks: **All** / **Active** / **Completed**
- Real-time statistics (active, completed, total)

### Subtasks
- Add subtasks to any task
- Progress bar showing completion percentage
- Collapsible subtask lists
- Independent drag-and-drop reordering per task

### Customization (Settings Panel)

```
+------------------------------------------+
|            Settings                [X]   |
+------------------------------------------+
|                                          |
|  Appearance                              |
|  +------------------------------------+  |
|  | Dark Mode              [ON /off]   |  |
|  |                                    |  |
|  | Accent Color                       |  |
|  | [blue] [purple] [pink] [green]     |  |
|  | [orange] [red] [rainb][gold]       |  |
|  |                                    |  |
|  | Font Size                          |  |
|  | [S] [M] [L] [XL]                   |  |
|  +------------------------------------+  |
|                                          |
|  Behavior                                |
|  +------------------------------------+  |
|  | Sound Effects          [ON /off]   |  |
|  | Haptic Feedback        [ON /off]   |  |
|  | Particles              [ON /off]   |  |
|  | Celebrations           [ON /off]   |  |
|  +------------------------------------+  |
|                                          |
|  Advanced                                |
|  +------------------------------------+  |
|  | Animation Speed   0.5x ====> 3.0x  |  |
|  | Particle Count    5 =========> 50  |  |
|  | [    Reset to Defaults           ] |  |
|  +------------------------------------+  |
|                                          |
+------------------------------------------+
```

### Visual Effects
- Animated particle background
- Celebration overlay with confetti on task completion
- Spring and bounce animations throughout the UI
- Gradient backgrounds and dynamic accent colors

### User Feedback
- Sound effects — Glass (add), Funk (delete), Pop (reorder)
- Haptic feedback on interactions
- Visual animations on every state change

---

## Tech Stack

```
+---------------------------------------------------+
|                    SwiftUI                        |
|            (Views, Animations, State)             |
+------------------------+--------------------------+
|                        |                          |
|     CoreData           |       Combine            |
|  (Persistence)         |  (@Published, reactive)  |
+------------------------+--------------------------+
|                        |                          |
|  UniformTypeIdentifiers|      SF Symbols          |
|   (Drag & Drop)        |      (All icons)         |
+------------------------+--------------------------+
```

**Zero third-party dependencies** — built entirely with Apple frameworks.

---

## Project Structure

```
TodoApp/
│
├── TodoAppApp.swift              # Entry point & CoreData injection
│
├── Views/
│   ├── ContentView.swift         # Main view — list, filters, stats
│   ├── TodoRowView.swift         # Task row + subtask UI
│   └── SettingsView.swift        # Settings panel
│
├── Models/
│   ├── Models.swift              # FilterType, AccentColor, FontSize, AppSettings
│   ├── CoreDataModels.swift      # CoreData extensions & CRUD manager
│   └── Persistence.swift         # PersistenceController (singleton)
│
├── Animations/
│   ├── AnimationComponents.swift     # Particles & celebration effects
│   ├── CelebrationManager.swift      # Global celebration state
│   └── ParticleBackgroundView.swift  # Background particle wrapper
│
└── Data/
    └── TodoApp.xcdatamodeld/     # CoreData schema
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                       UI Layer                          │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ ContentView  │  │ TodoRowView  │  │ SettingsView │   │
│  │              │  │              │  │              │   │
│  │ - Task list  │  │ - Checkbox   │  │ - Dark mode  │   │
│  │ - Filters    │  │ - Subtasks   │  │ - Colors     │   │
│  │ - Stats      │  │ - Progress   │  │ - Sounds     │   │
│  │ - Add input  │  │ - Drag/Drop  │  │ - Particles  │   │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘   │
│         │                 │                  │          │
└─────────┼─────────────────┼──────────────────┼──────────┘
          │                 │                  │
┌─────────┼─────────────────┼──────────────────┼──────────┐
│         ▼                 ▼                  ▼          │
│                   State Layer                           │
│                                                         │
│  @FetchRequest ←──── CoreData ────→ @Published          │
│  (reactive queries)   (SQLite)      (AppSettings)       │
│                                                         │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────┼───────────────────────────────┐
│                         ▼                               │
│                   Data Layer                            │
│                                                         │
│  ┌─────────────────┐     ┌──────────────────┐           │
│  │    TodoItem     │────►│   SubtaskItem    │           │
│  │                 │ 1:N │                  │           │
│  │ - text          │     │ - text           │           │
│  │ - isCompleted   │     │ - isCompleted    │           │
│  │ - timestamp     │     │ - timestamp      │           │
│  │ - sortOrder     │     │ - sortOrder      │           │
│  └─────────────────┘     └──────────────────┘           │
│                                                         │
│              PersistenceController (singleton)           │
└─────────────────────────────────────────────────────────┘
```

### State Management Flow

```
User Action ──► @State (local UI) ──► viewContext.save() ──► CoreData
                                                              │
                                              @FetchRequest ◄─┘
                                                    │
                                              SwiftUI View
                                             (auto-refresh)
```

---

## Requirements

| Requirement | Minimum Version |
|-------------|-----------------|
| Xcode       | 15.0+           |
| Swift       | 5.9+            |
| macOS       | 14.0+ (Sonoma)  |
| iOS         | 17.0+           |

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/moimat2345/Todo-app-in-swift.git
cd Todo-app-in-swift
```

### 2. Open in Xcode

```bash
open TodoApp/TodoApp.xcodeproj
```

### 3. Build & Run

```
Xcode ──► Select target (Simulator / Device) ──► Cmd + R ──► Done
```

> No additional setup needed — no pods, no packages, no API keys.

---

## CoreData Model

```
┌─────────────────────┐          ┌─────────────────────┐
│     TodoItem        │          │    SubtaskItem      │
├─────────────────────┤          ├─────────────────────┤
│ text        String  │          │ text        String  │
│ isCompleted Bool    │ 1    N   │ isCompleted Bool    │
│ timestamp   Date    │─────────►│ timestamp   Date    │
│ sortOrder   Int32   │ subtasks │ sortOrder   Int32   │
│                     │          │                     │
│ + parent    (self)  │          │ + parentTask        │
│ + children  (self)  │          │   (→ TodoItem)      │
└─────────────────────┘          └─────────────────────┘
```

---

## Screenshots

### Main View
![Main View](Screenshots/main-view.png)

### Adding a Subtask
![Add Subtask](Screenshots/add-subtask.png)

### Subtasks with Progress Bar
![Subtasks](Screenshots/subtasks.png)

### Full View with Multiple Tasks
![Full View](Screenshots/full-view.png)

### Filter — Completed Tasks
![Filter Completed](Screenshots/filter-completed.png)

### Filter — Active Tasks
![Filter Active](Screenshots/filter-active.png)

---

## License

This project is available under the [MIT License](LICENSE).
