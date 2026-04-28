<p align="center">
  <img src="AthLink/Assets.xcassets/athlinklogo.imageset/athlinklogo.png" alt="AthLink Logo" width="120"/>
</p>

<h1 align="center">AthLink</h1>

<p align="center">
  <strong>A two-sided marketplace connecting athletes with qualified coaches for personalized training.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017%2B-blue" alt="Platform"/>
  <img src="https://img.shields.io/badge/Swift-5.9-orange" alt="Swift"/>
  <img src="https://img.shields.io/badge/UI-SwiftUI-purple" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/Backend-Supabase-green" alt="Supabase"/>
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License"/>
</p>

---

AthLink is a native iOS application that connects athletes with qualified coaches for personalized training. Athletes can easily search, book, and pay for sessions, while coaches gain new clients and manage their business through the platform. The app handles everything from coach discovery and real-time messaging to session scheduling, payment tracking, and PDF receipt generation — all built with SwiftUI and backed by Supabase.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Database Design](#database-design)
- [Screenshots](#screenshots)
- [License](#license)

---

## Features

### Athlete Experience

| Feature | Description |
|:--|:--|
| **Coach Discovery** | Location-based search powered by zip code and GPS. Filter by sport, distance, hourly rate, name, and time availability. Results ranked via server-side RPC with geo-distance calculations. |
| **Session Booking** | Send direct requests to a specific coach or post an open session for any nearby coach to accept. Configure sport, session type (individual/group), date/time, training location via MapKit, and an optional message. |
| **Session Tracking** | View upcoming and past sessions with full details including sport, type, cost breakdown, location, and duration. |
| **In-App Messaging** | Real-time chat with coaches. Session request cards are embedded directly in the conversation for easy reference. |
| **Coach Profiles** | Browse a coach's sports, positions, achievements, experience, weekly availability grid, training locations on a map, pricing, and reviews. |
| **Reviews & Ratings** | Leave star ratings and written reviews after sessions. Aggregate ratings displayed on coach profiles. |
| **Account Management** | Edit personal info, upload a profile photo, toggle notification and messaging preferences, and manage payment methods. Unsaved changes trigger a confirmation prompt before navigating away. |

### Coach Experience

| Feature | Description |
|:--|:--|
| **Dashboard** | Dedicated home screen with quick access to jobs, messages, sessions, and account settings. Seamlessly switch between athlete and coach views. |
| **Job Management** | Three-tab workflow: **Requests** (incoming athlete requests), **Postings** (browse nearby open sessions with filters for distance, rate, and sport), and **Current Athletes** (track clients with per-athlete revenue). |
| **Session Calendar** | Visual calendar of upcoming sessions. |
| **Session Submission** | Completed sessions move to an "Unsubmitted" queue for review/editing before final submission. Submitted sessions display a full receipt with cost breakdown, 9% commission, and net payout. |
| **PDF Receipts** | Generate and share PDF receipts for any submitted session. |
| **Profile Management** | Configure personal quote, coaching achievements, experience, sports and positions, individual/group pricing, cancellation policy, training locations (MapKit), and a drag-to-select weekly availability grid. |

### Platform-Wide

| Feature | Description |
|:--|:--|
| **Authentication** | Email/password signup and login via Supabase Auth with persistent sessions, auto-refresh tokens, and email verification. |
| **Dual-Role Accounts** | A single user can operate as both an athlete and a coach, switching between views from the home screen. |
| **Location Services** | CoreLocation for auto-detecting zip codes, computing distances, and reverse geocoding. |
| **Safety** | OffenderWatch screening on every coach. Satisfaction guarantee program. |
| **Referral Program** | Users earn $80 for each successful referral. |

---

## Architecture

```
┌──────────────────────────────────────────────────┐
│                    SwiftUI Views                  │
│                                                  │
│   ┌───────────┐  ┌───────────┐  ┌───────────┐   │
│   │  Athlete  │  │   Coach   │  │  Shared   │   │
│   │   Views   │  │   Views   │  │   Views   │   │
│   └─────┬─────┘  └─────┬─────┘  └─────┬─────┘   │
│         └───────────────┼──────────────┘         │
│                         │                        │
│              ┌──────────▼──────────┐             │
│              │    RootViewObj      │             │
│              │  App State, Auth,   │             │
│              │  Navigation, GPS    │             │
│              └──────────┬──────────┘             │
│                         │                        │
│              ┌──────────▼──────────┐             │
│              │     ProfileID       │             │
│              │   User + Coach      │             │
│              │   Reactive State    │             │
│              └──────────┬──────────┘             │
└─────────────────────────┼────────────────────────┘
                          │
               ┌──────────▼──────────┐
               │      Supabase       │
               │                     │
               │  Auth  ·  Postgres  │
               │  Storage  ·  RPC    │
               └─────────────────────┘
```

### Design Decisions

- **`RootViewObj`** — A `@MainActor ObservableObject` serving as the single source of truth. Owns the Supabase client, navigation path, location manager, and user profile. Injected via `@EnvironmentObject` across the entire view hierarchy.
- **`ProfileID`** — An `ObservableObject` that maps backend DTOs (`Profile`, `CoachProfile`) to reactive `@Published` properties, cleanly separating the Codable data layer from the live UI state.
- **`NavigationStack`** — Programmatic, string-based `NavigationPath` routing enables deep linking and clean navigation management across both athlete and coach flows.
- **Swift Concurrency** — All asynchronous work uses native `async`/`await` with structured `Task` blocks. No Combine framework dependency.

---

## Tech Stack

| Layer | Technology |
|:--|:--|
| **Language** | Swift 5.9 |
| **UI** | SwiftUI |
| **Backend** | [Supabase](https://supabase.com) — Auth, PostgreSQL, Storage, RPC |
| **Maps & Location** | MapKit, CoreLocation |
| **Image Uploads** | Supabase Storage + PhotosUI (`PhotosPicker`) |
| **PDF Generation** | `UIGraphicsPDFRenderer` |
| **Minimum Target** | iOS 17+ |
| **IDE** | Xcode 15+ |

---

## Project Structure

```
AthLink/
├── AthLink/
│   ├── Essential/
│   │   ├── AthLinkApp.swift          # Entry point, Supabase init, root navigation
│   │   ├── HelperFunc.swift           # Data models, shared components, utilities
│   │   └── TestData.swift             # Development seed data
│   │
│   ├── Login/
│   │   ├── ExistingLoginView.swift    # Returning user login
│   │   ├── LoginScreen.swift          # New user signup (athlete/parent/coach)
│   │   └── CoachLogin.swift           # Extended coach registration flow
│   │
│   ├── Athlete/
│   │   ├── home.swift                 # Athlete home (tab view)
│   │   ├── Account/
│   │   │   └── Account.swift          # Profile editing, settings, payment
│   │   ├── Search/
│   │   │   ├── Search.swift           # Sport + zip code input
│   │   │   └── FSearch.swift          # Filtered results with sorting/filtering
│   │   ├── Session/
│   │   │   ├── Sessions.swift         # Upcoming & past sessions
│   │   │   ├── SessionInfo.swift      # Session detail view
│   │   │   └── RequestSess.swift      # Book or post a session (MapKit)
│   │   └── HomeHelpers/
│   │       ├── Satisfaction.swift     # Satisfaction guarantee
│   │       ├── Receive.swift          # Referral program
│   │       ├── Question.swift         # FAQ
│   │       └── Support.swift          # Contact support
│   │
│   ├── Coach/
│   │   ├── CoachHome.swift            # Coach home (tab view)
│   │   ├── Account/
│   │   │   ├── AccountView.swift      # Coach settings
│   │   │   └── CouchAccount.swift     # Extended profile editing
│   │   ├── Session/
│   │   │   ├── CoachSession.swift     # Calendar / unsubmitted / submitted
│   │   │   └── CoachCalendar.swift    # Visual session calendar
│   │   └── Jobs/
│   │       ├── Job.swift              # Requests / postings / current athletes
│   │       └── CoachRequestSess.swift # Request detail & accept view
│   │
│   └── Shared/
│       ├── Messages.swift             # Conversations list
│       ├── Chat.swift                 # Individual chat thread
│       ├── PrivacyPolicyView.swift    # Privacy policy
│       └── TermsOfServiceView.swift   # Terms of service
│
├── AthLinkTests/
├── AthLinkUITests/
├── .gitignore
├── LICENSE
└── README.md
```

---

## Getting Started

### Prerequisites

- Xcode 15+
- iOS 17+ device or simulator
- A [Supabase](https://supabase.com) project with the required tables and RPC functions

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/AthLink.git
   cd AthLink
   ```

2. **Configure Supabase credentials** in `AthLink/Info.plist`:
   ```xml
   <key>SUPABASE_URL</key>
   <string>https://your-project.supabase.co</string>
   <key>SUPABASE_PUBLISHABLE_API_KEY</key>
   <string>your-anon-key</string>
   ```

3. **Open in Xcode**
   ```bash
   open Athlink.xcodeproj
   ```

4. **Resolve packages** — Xcode will automatically fetch the Supabase Swift SDK via SPM.

5. **Build and run** on a simulator or physical device.

---

## Database Design

### Tables

| Table | Purpose |
|:--|:--|
| `profiles` | User accounts — name, type, avatar, notification preferences, session history, current coaches |
| `coach_profile` | Coach-specific data — sports, positions, pricing, achievements, experience, availability, training locations, session queues, current athletes |
| `posted_sessions` | Open session postings by athletes for coaches to browse and accept |
| `messages` | Chat messages between athletes and coaches with optional embedded session request data |
| `reviews` | Star ratings and written reviews from athletes to coaches |

### Server-Side RPC Functions

| Function | Purpose |
|:--|:--|
| `search_posted_sessions` | Geo-filtered, sortable search for nearby athlete postings |
| `move_past_sessions` | Migrates expired upcoming sessions to the unsubmitted queue |
| `get_coach_rating` | Returns aggregate star rating and review count for a coach |

---

## Screenshots

*Coming soon*

---

## License

This project is proprietary software. See [LICENSE](LICENSE) for full terms.

Copyright (c) 2025-2026 Ryan Aubrey. All rights reserved.
