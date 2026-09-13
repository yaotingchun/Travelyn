<h1 align="center">✈️ Travelyn — Your Collaborative Travel Companion & Planner</h1>

<p align="center">
  <strong>An AI-powered collaborative travel platform that unifies group trip planning, consensus vibe voting, live itinerary guidance, multimodal receipt splitting, and gamified Polaroid memory keeping.</strong>
</p>

<p align="center">
  <em><b>Travel</b> — Journey, adventure, and shared exploration</em> · <em><b>Lyn</b> — Linking companions and synchronizing itineraries seamlessly</em><br/>
</p>

<p align="center">
  <b>🚀 <a href="https://travelyn-ten.vercel.app/">Live Demo (Deployed Link)</a></b> •
  <b>🎥 <a href="https://youtube.com">Watch our Pitching Video (YouTube)</a></b> •
  <b>📊 <a href="https://canva.com">View our Presentation Slides</a></b>
</p>

---
## Team Introduction
| Member | Role | Responsibility |
| :--- | :--- | :--- |
| **Evelyn Ang** | Leader | **Backend Architecture & Documentation**: Architecting the backend services, coordinating project scope, presentation materials, and trip data pipelines. |
| **Angela Ngu Xin Yi** | Member | **AI Models & Cloud Deployment**: Developing multimodal Google Cloud Vision OCR pipelines, Gemini 2.5 Flash bill-splitting logic, CI/CD automation, and Vercel web deployment. |
| **Chun Yao Ting** | Member | **Frontend & Interactive UI/UX**: Engineering the Flutter cross-platform UI, dynamic itinerary timelines, location overview sheets, Polaroid camera check-in, and Travelyn mascot animations. |
| **Teoh Xin Yee** | Member | **Core Features & Social Integration**: Implementing the Discover & Travel Forum feeds, state management synchronization, debt settlement algorithms, and test suites. |

---
## Project Overview

### Problem Statement
-   **Scattered Across Too Many Apps**: Group travel is fragmented across chat apps, spreadsheets, expense calculators, and booking sites, causing severe planning fatigue.
-   **Group Decision Paralysis**: Clashing travel preferences, budgets, and dietary needs lead to endless debates with no structured way to reach a consensus.
-   **In-Trip Disruption & Rigid Schedules**: Real-world travel disruptions (weather changes, venue closures, transit delays) break rigid itineraries without context-aware alternatives.
-   **Awkward Bill Splitting & Currency Friction**: Splitting foreign paper dining receipts with local taxes, service fees, and uneven dish selections creates social tension and math errors.

### SDG Alignment
-   **SDG 9 (Industry, Innovation and Infrastructure)** — Uses AI, real-time data, maps, OCR, and intelligent trip planning to create an innovative digital travel solution.
-   **SDG 11 (Sustainable Cities and Communities)** — Helps travelers navigate destinations efficiently, discover local places, optimize routes, and adapt plans to reduce unnecessary travel.
-   **SDG 12 (Responsible Consumption and Production)** — Helps users manage travel budgets, compare prices, avoid unnecessary spending, and make more informed consumption decisions during trips.

### Solution Description
Travelyn is an all-in-one collaborative mobile and web platform guided by **Travelyn**, a friendly animated explorer mascot. Travelyn empowers travel groups to vote visually on trip vibes, follow dynamic daily schedules, and manage flights, stays, and trains in a unified hub. It eliminates post-meal math arguments through multimodal AI receipt photo scanning and immortalizes every stop with vintage Polaroid check-in keepsakes and passport badges.
-   **AI-Augmented In-Trip Intelligence** — Context-aware detour suggestions, weather alerts, and real-time chat guidance.
-   **Effortless Group Consensus** — Interactive 3×3 vibe voting and automated preference-balanced itineraries.
-   **Multimodal Financial Harmony** — Instant paper receipt OCR, line-item dish claiming, and multi-currency debt minimization.
-   **Gamified Scrapbook Keepsakes** — Landmark viewfinder check-ins, washi-taped Polaroid memory cards, and collectible Explorer Passport stamps.

---
## Ideation & Process

### 2.1 Ideas We Considered
Every distinct feature idea was systematically evaluated against user friction, technical complexity, and product differentiation. Chosen ideas that define Travelyn's core experience are prioritized below:

| Idea / Feature | Status | Why it was Kept / Dropped |
| :--- | :---: | :--- |
| **AI Travel Companion & In-Trip Planning** | **Kept (Core)** | Chosen as a key feature because the AI companion supports travelers throughout the trip, not just during the planning stage. It provides contextual recommendations, itinerary guidance, reminders, route suggestions, and warnings based on the user's current trip plan and situation. Instead of simply displaying a fixed itinerary, the companion helps users decide what to do next, where to go, and how to adjust their plans when circumstances change. Risk detection is integrated into the companion to identify potential issues such as delays, closures, bad weather, or scheduling conflicts and suggest suitable alternatives. |
| **AI Group Preference Matching & Conflict Resolution** | **Kept (Core)** | Kept because it solves the same problem of conflicting group preferences. The system combines members' travel styles, budgets, and interests to identify compatible activities and create a more balanced trip, rather than relying only on manual voting. |
| **Automatic Trip Re-planning & What-If Simulation** | **Kept (Core)** | Kept because both features focus on adapting the itinerary when plans change. Users can either respond to real-world disruptions or explore hypothetical changes and see how they affect the rest of the itinerary. |
| **AI Itinerary Generation & Personalized Recommendations** | **Kept (Supporting)** | Kept as a supporting feature because the AI-generated itinerary provides the initial trip plan while personalized recommendations help fill it with suitable activities and places. Generic travel recommendations are therefore integrated into the planning process instead of being a separate feature. |
| **AI Receipt Scanning, Expense Splitting & Budget Tracking** | **Kept (Core)** | Kept because these features form one complete expense-management workflow. Receipt scanning extracts expenses, expense splitting determines who owes what, and budget tracking monitors spending against the group's planned budget. |
| **Interactive Trip Map & Route Planning** | **Kept (Supporting)** | Kept as a supporting feature because it provides a visual representation of the itinerary and helps users understand distances, routes, and travel times. |
| **Group Voting & Social Trip Chat** | **Kept (Supporting)** | Kept as supporting features because both help the group communicate and make decisions. Voting allows members to express preferences, while the shared chat keeps discussions, itinerary decisions, and AI suggestions in one place. |
| **Booking & Trip Readiness Checklist** | **Kept (Supporting)** | Kept as a supporting feature because the booking checklist and general trip-readiness checks serve the same purpose: reminding users about reservations, tickets, and other preparations that need to be completed before or during the trip. |
| **Real-Time Flight & Hotel Price Comparison** | **Kept (Supporting)** | Kept because comparing prices across providers helps users make better booking decisions without manually checking multiple platforms. It complements the itinerary and budget features by providing current travel costs. |
| **Booking Aggregation & Deep-Link Booking** | **Kept (Supporting)** | Kept instead of a full booking system because the application can compare available options and redirect users to established booking providers. A full in-app booking system was dropped because it would introduce additional payment, merchant, cancellation, and compliance requirements. |
| **AI Travel Cost Prediction** | **Merged** | Merged into Expense & Budget Management because it overlaps with the existing budget tracking functionality. Future cost estimates can be generated using itinerary and historical expense information rather than being a separate feature. |
| **Travel Simulation / Dependency Graph** | **Merged** | Merged into Automatic Trip Re-planning because the dependency logic is useful for determining what is affected when an itinerary changes, but exposing a complex graph as a separate feature would add unnecessary UI complexity. |
| **Multi-Language Travel Assistance** | **Deferred** | Moved to future development because language support is useful for international travellers, particularly for understanding receipts and other travel information. Rather than building a separate language assistant, multilingual functionality is integrated into existing AI features. |
| **Offline Travel Support** | **Deferred** | Moved to future development because full offline support would require additional work for synchronizing maps, itineraries, and AI functionality. Basic local fallback capabilities can still be retained. |
| **AI Packing List Generator** | **Dropped** | Dropped because packing recommendations are common and do not strongly differentiate the application from existing travel solutions. |
| **Personalized Destination Comparison** | **Dropped** | Dropped because it overlaps with group preference matching and personalized recommendations without providing enough additional value to justify a separate feature. |
| **Full In-App Booking System** | **Dropped** | Dropped because directly processing bookings would significantly increase technical, financial, and compliance requirements. The current aggregator and deep-link approach provides the required functionality with less complexity. |

---

### 2.2 Ideation Boards
Our team mapped out user journeys, problem trees, and collaborative flows to explore where group friction arises and how automated intelligence can solve them:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 IDEATION MINDMAP & FLOW                                │
├────────────────────────────────────────────────────────────────────────────────────────┤
│  [Pain Point: Group Decision Paralysis]                                                │
│      ├── Clashing travel vibes ────► Solution: 3×3 Visual Vibe Voting Grid             │
│      └── Endless chat debates ─────► Solution: In-Chat AI Moderation & Consensus Cards │
│                                                                                        │
│  [Pain Point: Rigid & Fragile Schedules]                                               │
│      ├── Delays / Crowds ──────────► Solution: Schedule Time-Lag Realignment Sheet     │
│      └── Venue closures ───────────► Solution: 3D Flip Alternative Swap                │
│                                                                                        │
│  [Pain Point: Expense & Currency Friction]                                             │
│      ├── Wrinkled foreign receipts ► Solution: Cloud Vision OCR + Gemini Line-Item     │
│      └── Awkward who-owes-what ────► Solution: Greedy Pairwise Multi-Currency Reducer  │
│                                                                                        │
│  [Pain Point: Cluttered & Lost Memories]                                               │
│      └── Passive photo dumps ──────► Solution: Polaroid Landmark Check-In & Diary      │
└────────────────────────────────────────────────────────────────────────────────────────┘
```
> *Figure 1: Problem Tree and Solution Synthesis — Mapping user frustrations across group planning, in-trip disruption, and expense settlement into Travelyn's core product modules.*

---
## Key Features
-   **Real-Time Collaborative Trip Chat**: In-trip group feed where Travelyn injects contextual suggestion cards (nearby cafes, detour alerts) with one-tap action buttons.
-   **Mascot-Driven Vibe-Casting (3×3 Grid)**: Group members vote on trip vibes (*Foodie*, *Culture*, *Adventure*, *Chill*) with live avatar clustering to automatically shape itineraries.
-   **Smart Daily Itinerary & Location Sheets**: Timeline view with walking durations, opening hours, local dish recommendations, and interactive Mapbox routing.
-   **Multimodal AI Receipt Scanner & Bill Splitter**: Snap physical paper receipts to extract line items, taxes, and service fees via Vision OCR + Gemini 2.5 Flash, with multi-currency debt minimization.
-   **Live Camera Check-In & Polaroid Scrapbook**: Landmark camera viewfinder with focus brackets that prints vintage Polaroid cards with washi tape and postal stamps into a trip diary.
-   **Gamified Explorer Passport & World Map**: Interactive projected world map tracking explored destinations, XP leveling, and collectible achievement badges (*Peak Seeker*, *Foodie*, *Culture Lover*).
-   **Spontaneous "Surprise Me" Generator**: One-tap downtime generator that crafts instant mini-adventures when free time opens up between scheduled stops.
-   **Itinerary-Aware Booking Hub**: Curated stays, flights, and trains labeled with smart badges (*"Closest to itinerary"*, *"Best arrival time"*).
-   **Community Travel Forum**: Social hub to explore verified local advice, transit hacks, and hidden spots shared by fellow travelers.

---

### 📱 Key Screens & Interactions

Travelyn’s design language is warm, tactile, and gamified—blending modern Flutter micro-interactions with nostalgic scrapbook aesthetics (washi tape, vintage Polaroid cards, postal stamps, and smooth mascot animations). You can explore each of the interactive screens and simulation flows live on our [**Web Demo (travelyn-ten.vercel.app)**](https://travelyn-ten.vercel.app/).

<div align="center">
  <img src="./Key%20Screens.jpg" alt="Travelyn Key Screens & UI Showcase" width="100%" />
</div>

---

#### 1. Explorer Onboarding & Sign-In (`SignInScreen`)
* **Screen Context:** Welcome and account authentication experience displayed on the handheld mobile device.
* **Core Interaction:** Travelers log in via email/password or use one-tap federated sign-in with Google or Apple. The "Remember me" toggle and instant account registration link provide a seamless entry point into the app.
* **UI/UX Highlights:** Warm cream paper texture, an animated waving Shiba explorer mascot (*"Welcome back, Explorer!"*), high-contrast rounded text fields, and prominent terracotta CTA buttons designed for comfortable one-handed thumb interaction.

---

#### 2. Social Wishlist & Place Link Ingestion (`WishlistCollectorScreen`)
* **Screen Context:** Collaborative place harvesting screen (*"Anything you wanna go?"*).
* **Core Interaction:** Before the itinerary is finalized, group members paste links from RedNote (Xiaohongshu), Instagram Reels, TikTok, or Google Maps directly into the input bar (`Paste RedNote, IG Reel, or place name...`). The system extracts venues and renders contributor cards (e.g., *Sarah · IG Reel: Tokyo Sunset Spots & Aesthetic Rooftops*, *Kenji · RedNote: Must-Try Ramen*, *Elena · Maps*). A bottom progress button tracks group readiness: `Ready! (3/4) ✨`.
* **UI/UX Highlights:** Visual social platform icons (Instagram, RedNote, Google Maps), real-time contributor attribution tags, automated location count chips (*"3 locations detected"*), and a group consensus counter that ensures every member has input before plan generation.

---

#### 3. Smart Step-by-Step Daily Itinerary & Street Map (`TripTab`)
* **Screen Context:** Multi-day journey coordinator for Tokyo, Japan (12 Sep – 15 Sep 2026).
* **Core Interaction:** Travelers toggle between travel days using interactive date chips (`08.09 SUN`, `09.09 MON`, `10.09 TUE`, `11.09 WED`). An integrated top street map plots sequenced pinpoints (1 through 6) linked to the chronological timeline below.
* **UI/UX Highlights:** Structured time blocks (`08:30 · Breakfast`, `09:36 · Sightseeing`), thumbnail imagery for each venue, walking transit badges (`24 min walk / 1.4 km`), specialty meal recommendations, and persistent navigation tabs (`Chat`, `Trip`, `Bookings`, `Diary`, `Finance`) with warm terracotta active states.

---

#### 4. Geofenced Arrival & Destination Discovery (`ArrivalModal`)
* **Screen Context:** Contextual landmark arrival dialog (*"We've arrived at Bread, Espresso & Arashiyama Garden, Kyoto!"*).
* **Core Interaction:** When GPS geofencing detects that the group has reached a scheduled destination, an arrival modal slides up automatically. Travelers view destination photography, category badges (`First Stop`, `Bakery & Cafe`, `Arashiyama / Kyoto`), cultural background, and Travelyn's curated recommendation before tapping `Start Exploring`.
* **UI/UX Highlights:** Rich imagery showcase, celebration sparkle icons, dedicated mascot insider tip bubble (*"Try the signature honeycomb French toast and hand-dripped siphon coffee!"*), and a single high-contrast action trigger to smoothly transition into the visit.

---

#### 5. Schedule Time-Lag Realignment & Weather Adaptation (`TripScheduleSyncSheet`)
* **Screen Context:** In-trip disruption handling (*"Running ~25m Behind"*).
* **Core Interaction:** When a group spends extra time at a location (e.g., lingering at Meiji Jingu Shrine) and outdoor conditions change, Travelyn calculates the time-lag and current weather conditions (`+25m spent`, `15°C Rain`, `Sky Safe`). It dynamically shifts downstream stops (Takeshita Street sheltered walk, AFURI Ramen, Shibuya Sky) and prompts the group with `Let's go! 🚀` or `Stay on plan`.
* **UI/UX Highlights:** Reassuring companion mascot prompt (*"No worries! I shifted the morning times so you can enjoy everything without rushing ✨"*), environmental warning badges, transparent schedule recalculation, and one-tap group timeline synchronization.

---

#### 6. Live Viewfinder Landmark Camera Check-In (`TripCameraCheckinScreen`)
* **Screen Context:** In-app check-in camera (*"Let's capture this moment! 📸"*).
* **Core Interaction:** Travelers open an in-app viewfinder framed with landmark corner brackets and location badges. An animated Shiba mascot dressed in full explorer gear guides the photo check-in. Travelers can toggle camera flash, flip lenses, and tap the glowing shutter button to capture the moment.
* **UI/UX Highlights:** Immersive full-screen camera overlay, 3D explorer mascot pose against destination backdrops, tactile haptic shutter feedback with subtle white flash, and instant pipeline routing into the keepsake generator.

---

#### 7. Tokyo Memories & Vintage Polaroid Diary (`DiaryTab`)
* **Screen Context:** The permanent shared scrapbooking timeline (*"Tokyo Memories & Polaroids"*).
* **Core Interaction:** Check-in photos are automatically transformed into retro Polaroid cards pinned along a shared chronological trip timeline. Each card preserves the photo, destination name (*Chatel Hatou / 茶亭 羽當*), category tag (*Morning Coffee ☕*), timestamp (*08:30 AM · Day 1*), and personal diary reflection notes.
* **UI/UX Highlights:** Authentic washi tape graphics, Japanese and English bilingual typography, delicate drop shadows, postal stamp graphics, and an organized count of trip highlights (*"7 Highlights"*).

---

#### 8. Spontaneous Downtime "Tiny Detour?" Engine (`TinyDetourDialog`)
* **Screen Context:** Smart nearby hidden gem suggestion (*"Tiny detour?"*).
* **Core Interaction:** During downtime or gaps between planned itinerary stops, the AI companion detects walking-distance gems matching the group's collective taste profile (e.g., *Ura-Harajuku Local Market · 300m from you · 12 min*). Travelers can inspect venue details, tap `Let's go! 🚀` to seamlessly add it to their daily route, or choose `Stay on plan`.
* **UI/UX Highlights:** Cheerful peeking mascot with sparkles, real-time proximity and walking duration badges, tag pills (`Local Food`, `Hidden Gem`), and a frictionless two-button decision card.

---

#### 9. In-Chat Disruption Alert & Instant Alternative Swap (`ChatTab`)
* **Screen Context:** Real-time conversational group chat with inline AI arbitration (*"@Travelyn the cafe is closed :("*).
* **Core Interaction:** When an unexpected venue closure occurs, any group member can tag the AI in chat (*"@Travelyn the cafe is closed :("*). Travelyn instantly diagnoses the issue, suggests a highly-rated backup around the corner (*Chatei Hatou · 2 min walk / 180m · ★ 4.8*), and offers inline action buttons: `Skip Cafe` or `Swap Cafe`.
* **UI/UX Highlights:** Zero context switching—disruptions are resolved directly within the natural group conversation; inline swap preview card with walk times and ratings; and one-tap itinerary updates that synchronize across all members' devices in real time.

---
## What Makes It Different

Instead of forcing users to juggle separate spreadsheets, expense calculators, and booking sites, Travelyn brings planning, in-trip dynamic replanning, bill-splitting, booking, and memory keeping into one warm, gamified companion app.

### Novel Features & The Twist

1. **Interactive Vibe Voting & Consensus-First Generation**
   * **The Twist:** Instead of an organizer drafting a rigid plan first that friends have to awkwardly modify, all members join the trip lobby first and vote on a visual 3×3 grid of trip vibes (*Foodie*, *Culture*, *Adventure*, *Chill*, *Hidden Gems*, etc.). The AI synthesizes the itinerary only after capturing everyone's preferences.
   * **Why It's Original:** It eliminates the friction of single-planner burden and "plan-first, adjust-later" bias, visualizing group consensus in real time with member avatars and creating a harmonious itinerary tailored to the whole group from day one.

2. **Contextual In-Trip Planning & Dynamic Re-Planning**
   * **The Twist:** Most travel apps are rigid itineraries that go silent the moment a trip begins. Travelyn functions as an active, in-trip AI copilot embedded directly within the collaborative group chat.
   * **Why It's Original:** It transforms static planning into adaptive real-world execution. If a venue is unexpectedly closed, Travelyn executes a smooth 3D flip card swap with an open, highly-rated alternative within walking distance; if an activity runs overtime, it realigns downstream schedules so no reservations are missed; and if group members debate alternatives, it arbitrates with inline consensus vote cards.

3. **AI Receipt Scanning & Itemized Bill Splitting**
   * **The Twist:** Uses vision AI to scan physical paper receipts in any language or currency.
   * **Why It's Original:** It breaks down individual dishes, taxes, and service fees so friends simply tap what they ate to split accurately, while automatically minimizing debt settlements across 11+ global currencies.

4. **Gamified Explorer Passport & Tactile World Map**
   * **The Twist:** Replaces boring profile settings with a collectible vintage explorer passport.
   * **Why It's Original:** Features an interactive world map tracking *Explored*, *Wishlist*, and *Someday* countries, rewarding travelers with ranks, XP, and unlockable achievement badges like *Foodie* and *Peak Seeker*.

5. **Live Camera Check-Ins & Polaroid Keepsakes**
   * **The Twist:** An in-app viewfinder check-in camera that rewards you at every landmark.
   * **Why It's Original:** Snapping a photo instantly generates a vintage Polaroid card with washi tape, location tags, and mascot postal stamps, saving them directly into your trip's memory timeline.

6. **"Surprise Me" Downtime Adventure Engine**
   * **The Twist:** A one-tap spontaneous discovery button built into the main feed.
   * **Why It's Original:** Whenever you have unexpected free time between scheduled stops, Travelyn generates quick, nearby mini-adventures on demand.

7. **Itinerary-Aware Booking Hub**
   * **The Twist:** Combines stays, flights, and trains with intelligent itinerary context.
   * **Why It's Original:** Tags options with smart badges like *"Closest to itinerary"* and *"Best arrival time"* so your logistics always match your daily plans.

### Comparison with Existing Solutions

| Feature / Capability | **Travelyn** | **Wanderlog** | **Splitwise** | **Polarsteps** |
| :--- | :---: | :---: | :---: | :---: |
| **All-in-One Trip Flow** *(Plan + Book + Split + Journal)* | ✅ **Yes** | ⚠️ Partial | ❌ Expenses only | ❌ Journal only |
| **AI Paper Receipt OCR & Line-Item Split** | ✅ **Built-in (Gemini AI)** | ❌ None | ⚠️ Paid Pro only | ❌ None |
| **Group Vibe-Casting & Consensus Voting** | ✅ **Visual 3×3 Grid** | ❌ Basic text lists | ❌ None | ❌ None |
| **In-Trip Planning & Dynamic Replanning** | ✅ **Real-time AI Copilot & 3D Swaps** | ❌ Static schedule only | ❌ None | ❌ None |
| **Polaroid Camera Check-Ins with Stamps** | ✅ **Interactive Keepsakes** | ❌ None | ❌ None | ⚠️ Standard photos |
| **Gamified Explorer Passport, XP & World Map** | ✅ **Yes (Stamps & Ranks)** | ❌ Basic list | ❌ None | ⚠️ Travel stats only |
| **"Surprise Me" Free-Time Planner** | ✅ **One-Tap Nearby Gems** | ❌ None | ❌ None | ❌ None |
| **Itinerary-Smart Booking Recommendations** | ✅ **Smart Context Badges** | ⚠️ Generic links | ❌ None | ❌ None |

---
## Technology Architecture

<div align="center">
  <img src="./Architecture%20Diagram.png" alt="Travelyn Architecture Diagram & Core System Flows" width="100%" />
</div>


### 🛠️ Technology Stack Overview

### 1. Frontend Layer
* **Technology:** **Flutter (Dart)**
* **Why Flutter?**
  * **One Codebase:** Develop and maintain the core application once across iOS, Android, and Web/PWA instead of maintaining separate native codebases.
  * **Smooth 60 FPS UI:** Flutter provides native-compiled performance for highly interactive travel features such as maps, itinerary timelines, bottom sheets, and mascot animations.
  * **Strong Ecosystem:** Robust open-source libraries such as `flutter_map`, Mapbox integrations, and Google Fonts (`Plus Jakarta Sans`) accelerate UI implementation.
  * **Dart's Sound Type System:** Vital for managing complex multi-day state machines, group expenses, itemized bill splits, and offline travel payloads safely.
* **Constraints & Trade-offs:**
  * **Client Security:** API keys and service account credentials are never bundled into mobile or web builds to prevent reverse-engineering. All sensitive operations (AI processing, OCR, third-party travel queries) are proxied through our backend.
  * **Web Asset Weight:** Flutter Web bundles are larger than raw HTML/JS. We mitigate this through client-side asset optimization, browser caching, and Cloud CDN edge delivery.

---

### 2. Backend Application Layer
* **Technology:** **Google Cloud Run with Node.js (Fastify/TypeScript), Go, or Python (FastAPI)**
* **Why Cloud Run?**
  * **Serverless Simplicity:** Fully managed infrastructure with zero operational server maintenance.
  * **Elastic Auto-Scaling:** Automatically scales container instances up to absorb concurrent group travel sessions, and scales down to zero when idle to minimize costs.
  * **Native GCP Ecosystem Integration:** Direct IAM-authenticated communication with Vertex AI, Cloud Vision, Cloud SQL, Secret Manager, and Cloud Storage.
  * **Containerized Portability:** Packaging services inside Docker containers avoids vendor lock-in, enabling runtime flexibility across FastAPI, Fastify, or Go.
* **Constraints & Trade-offs:**
  * **Cold Starts:** When scaling from zero, the first request may experience initialization latency. Mitigated by setting a minimum instance count for latency-sensitive routes and using lightweight runtimes.
  * **Stateless Design:** Cloud Run containers are stateless. Ephemeral session state, rate-limiting counters, and short-term AI results are offloaded to Redis, while background queues are handled via Cloud Tasks.

---

### 3. Database, File Storage & Caching

#### Primary Collaborative Database: Google Cloud Firestore
* **Architecture:** Structured around real-time collaborative collections:
  * `Users`: User profiles, travel preferences, explorer passport ranks, and unlocked badges.
  * `Trips`: Trip metadata, destinations, date ranges, and participating member avatars.
  * `Itineraries`: Dynamic daily schedules, activity cards, and opening hours.
  * `Expenses`: Group spending records, currency codes, and pairwise debt matrices.
  * `Receipts`: OCR metadata, raw item extractions, tax/service fee breakdowns, and payer claims.
  * `Notifications`: Real-time group alerts, flight updates, and in-trip AI recommendations.
* **Why Firestore?** Real-time multi-client synchronization propagates itinerary changes, vote updates, and bill splits across all group members instantly without manual polling. Native offline caching ensures travelers can view their schedules even in areas with spotty connectivity.
* **Cost & Read/Write Optimization:**
  * Carefully structured shallow subcollections and targeted composite indexes.
  * Strict listener lifecycle management to prevent memory leaks and unnecessary read triggers.
  * Client-side caching so screens only request newly updated delta documents.

#### Object Storage: Google Cloud Storage (GCS)
* **Usage:** Secure storage for large binary assets including receipt photos, user avatars, generated Polaroid keepsakes, and exported PDF itineraries.
* **Security:** Buckets remain strictly private. The backend generates short-lived, cryptographically signed URLs for uploads and downloads, preventing unauthorized public access.

#### In-Memory Caching: Google Cloud Memorystore (Redis)
* **Usage:** High-speed cache for frequently requested map route geometries, temporary travel search availability, rate-limiting counters, and short-lived AI extractions.
* **Benefit:** Drastically slashes latency and avoids duplicate billing on third-party APIs (e.g., repeatedly querying the same route between a hotel and a landmark).

---

### 4. APIs & Third-Party Services

* **Multimodal AI & Receipt Processing:**
  * **Google Cloud Vision API + Vertex AI (Gemini):** Cloud Vision extracts raw OCR text and bounding boxes from wrinkled receipts in any language. Vertex AI (Gemini 2.5 Flash) structures the raw text into structured JSON containing dishes, item prices, tax brackets, service charges, and currencies.
  * *Constraint Mitigation:* Large images are compressed and downscaled client-side before upload to reduce payload sizes and AI processing latency.
* **Maps & Navigation:**
  * **Mapbox Directions API + Vector Tiles:** Powers interactive map pins, turn-by-turn walking times, and route polyline rendering.
  * *Constraint Mitigation:* Commonly traveled route segments are cached in Redis to stay well within API quota limits.
* **Identity & Authentication:**
  * **Firebase Authentication / Google Identity Platform:** Handles secure registration, social logins (Google, Apple), and email/password authentication, issuing verified JWTs for backend API authorization.
* **Travel Booking Integrations (Future Scope):**
  * **Amadeus / Skyscanner / Booking.com APIs:** Aggregates real-time availability for stays, flights, and trains. Responses are normalized on the backend into a clean, uniform schema before delivery to the frontend.

---

### 5. Hosting & Deployment Infrastructure (GCP)

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Backend API** | **Google Cloud Run** | Executes containerized backend microservices with automatic request-based scaling |
| **Web / PWA Hosting** | **Cloud Storage + Cloud CDN / Vercel** | Delivers static Flutter Web assets globally with edge caching and SSL termination |
| **Primary NoSQL Database** | **Google Cloud Firestore** | Stores collaborative users, trips, real-time itineraries, expenses, and receipts |
| **Relational Database** | **Cloud SQL (PostgreSQL)** | Manages relational financial records, historical logs, and spatial PostGIS data |
| **File Storage** | **Google Cloud Storage (GCS)** | Private bucket storage for receipt images, Polaroid keepsakes, and PDF exports |
| **Caching Layer** | **Cloud Memorystore (Redis)** | High-throughput in-memory cache for map routes, API lookups, and session tokens |
| **Secret Management** | **Google Secret Manager** | Securely manages API credentials, database keys, and JWT signing certificates |
| **Security & Routing** | **Cloud Load Balancing + Armor** | HTTPS termination, DDoS defense, IP rate limiting, and global traffic routing |
| **CI/CD Pipeline** | **GitHub Actions + Artifact Registry** | Automates code linting, unit test suites, Docker image builds, and Cloud Run deployments |

* **Why GCP?** Unifying services within Google Cloud enables zero-trust IAM authentication between Cloud Run, Vertex AI, Cloud Vision, Cloud SQL, and Secret Manager without exposing internal network endpoints or managing separate cloud vendor accounts.
* **Continuous Delivery:** Every push to `master` triggers a GitHub Actions pipeline that runs static analysis (`flutter analyze`), executes unit tests, builds optimized Docker container images, registers them in GCP Artifact Registry, and performs blue-green zero-downtime deployments to Cloud Run.

---
## System Feasibility & Scalability

### System Feasibility
- **Technical Feasibility**: Flutter compiles to single-binary native performance across iOS, Android, and Web. Multimodal tasks leverage Gemini 2.5 Flash for low latency (<1.5s) and cost-efficient structured JSON extraction.
- **Economic Feasibility**: By functioning as an intelligent booking aggregator rather than a direct merchant of record, Travelyn avoids costly payment compliance (PCI-DSS) and booking cancellation overhead while monetizing through affiliate deep links.
- **Operational Feasibility**: The scrapbook-inspired aesthetic (washi tape, Polaroid cards, and Travelyn the Mascot) transforms dry logistical travel coordination into an engaging, accessible experience for non-technical users.

### Scalability
- **Client & Device Scalability**: Adaptive layout breakpoints ensure seamless responsiveness from mobile screens (iOS & Android) up to full desktop web viewports.
- **Cloud & Data Scalability**: FastAPI's asynchronous event loop combined with Redis response caching and PostGIS geospatial indexing ensures rapid query resolution even during peak holiday travel seasons.

---
## Business & Impact

### Market Segments
- **Gen Z & Millennial Group Travelers**: High-frequency leisure travelers who value shared experiences, aesthetic social memories, and transparent group bill splitting without awkward conversations.
- **Backpackers & Independent Explorers**: Budget-conscious travelers seeking spontaneous recommendations, XP-driven passport gamification, and itinerary-optimized bookings.
- **Campus Clubs, Societies & Small Teams**: Student associations and corporate retreat organizers requiring consensus-based voting and hassle-free expense accounting.

### Business Model
- **Business-to-Consumer (B2C) — Freemium**:
  - *Free Tier*: Core collaborative trip planning, voting grid, standard itinerary tracking, and basic receipt splitting.
  - *Travelyn Explorer Pass (Subscription / In-App)*: High-resolution Polaroid cloud backup, offline map caching, priority Gemini 2.5 replanning, and exclusive collectible passport badge styles.
- **Business-to-Business (B2B) — Affiliate & Local Partnerships**:
  - Affiliate revenue from deep-linked hotel, flight, and attraction bookings (Skyscanner, Booking.com, Klook).
  - Sponsored "Hidden Gem" spotlights and curated local merchant partnerships for authentic neighborhood cafes and cultural activities.

### Social Impact
- **Fostering Real-World Human Connection**: Removes administrative friction and financial stress from group trips, allowing friends to focus on shared bonding and discovery.
- **Decentralizing Tourism**: Surfaces lesser-known neighborhood vendors, local markets, and cultural heritage spots beyond crowded commercial tourist traps.
- **Promoting Cultural Curiosity**: Explorer passport stamps and landmark check-ins encourage respectful engagement with local history, gastronomy, and customs.

### Sustainability
- **Eco-Conscious Transit Prioritization**: Itineraries emphasize pedestrian walking routes, train connections, and metro systems over carbon-heavy private taxis.
- **100% Paperless Digital Travel**: Replaces printed itineraries, vouchers, and paper dining receipts with cloud-synced digital tracking.
- **Responsible Foot-Traffic Dispersal**: Real-time crowd and opening-hour insights guide groups to visit attractions during off-peak times, reducing local strain.

---
## Mentor Consultation & Iterations

Our project evolved through intensive mentor consultations, transitioning from a broad, multi-feature concept into a tightly focused, high-impact travel companion with interactive in-trip intelligence.

### 📅 Consultation Feedback Summary

| <div style="min-width: 95px">Date</div> | <div style="min-width: 125px">Mentor</div> | <div style="min-width: 400px">Core Feedback Received</div> | <div style="min-width: 430px">Strategic Pivot & System Iteration</div> |
| :--- | :--- | :--- | :--- |
| **01/09/2026** | **Teh Ming En** | • **Scope Overload & Pruning**: Too many peripheral features dilute user focus; prune generic tools (e.g., packing lists).<br>• **Shift from "Plan First, Adjust Later" to "Join & Vote First, Generate Together"**: Previously, our workflow was designed where an initial itinerary would be generated first by the trip creator, and other invited members would then manually adjust or negotiate it. She pointed out that this top-down flow creates anchoring bias and social friction (friends feel awkward dismantling someone's pre-made plan). She strongly recommended having **all members join the trip lobby first**, and only generating the AI itinerary **after capturing and analyzing everyone's collective preferences and vibes**.<br>• **Email API for Emergency Detection**: Suggested using an Email API to parse booking emails and detect emergency disruptions like flight delays.<br>• **Elevate "Wow Features"**: Stand out through memorable, differentiated user experiences.<br>• **UI/UX Craftsmanship**: Great concept requires meticulous attention to visual polish, transitions, and micro-interactions. | • **Consensus-First Vibe Voting & Generation (`TripVotingScreen`)**: Completely abandoned the single-creator draft-and-adjust model. Now, the trip creator creates a room and invites members first. All friends join the trip lobby and simultaneously cast their votes on a visual 3×3 Vibe Card Grid (*Foodie*, *Culture*, *Adventure*, *Chill*, *Hidden Gems*). The AI synthesizes the unified, balanced itinerary only after analyzing the collective preferences of all joined members, ensuring equal voice from the outset.<br>• **Pruned Scope & Rejected Email API**: Dropped generic packing lists and direct booking gateways. • **Intentionally rejected Email API parsing** because the vast majority of real-world travel emergencies (e.g., sudden bad weather, spontaneous venue closures, subway delays, or groups lingering behind schedule) are localized and cannot be traced through email. Instead, we shifted focus to active in-trip contextual monitoring and direct simulation triggers.<br>• **Elevated Core Pillars**: Accelerated development of the **In-Trip AI Companion**, **Multimodal Receipt OCR Bill Splitting**, and **Polaroid Landmark Check-Ins**.<br>• **Scrapbook Design Language**: Crafted a tactile aesthetic with Plus Jakarta Sans typography, washi tape accents, vintage stamps, and 60 FPS haptic card transitions. |
| **12/09/2026** | **Mah Qing Fung** | • **In-Chat Conflict Resolution**: Don't force users into separate planning forms; handle location disagreements directly inside group chat.<br>• **Polaroid Landmark Check-In**: Highlighting this as a unique, highly memorable signature feature.<br>• **Dynamic Replanning is Essential**: Real travel is unpredictable; the app must dynamically adapt to venue closures, delays, and spontaneous detours.<br>• **Streamlined Demo Journey**: Center the presentation on the triumvirate: **Chat** → **Itinerary (Trip)** → **Diary**. | • **In-Stream Resolution (Simulation 1)**: Integrated consensus voting and AI compromise suggestions directly into the group chat feed (`_isConflictSimulationActive`).<br>• **Real-Time Simulation Suite (Simulations 1–6)**: Built an interactive simulation events sheet (`TripSimulationEventsSheet`) to demonstrate live handling of 6 real-world travel disruption scenarios.<br>• **Integrated Memory Diary**: Linked the camera check-in viewfinder directly to the permanent scrapbooked `DiaryTab`. |

---

### 🔄 System Evolutions & Key Architectural Shifts

#### 1. From "Plan First, Adjust Later" to "Join & Vote First, Generate Together" (Consensus-First Planning)
* **The Problem**: In our original workflow, a trip organizer generated a preliminary itinerary first, and other invited members had to review and adjust it. This placed the entire planning burden on one person, established an "anchoring bias" where the initial plan dominated, and created social hesitation when friends felt uncomfortable suggesting major overhauls to an already-generated plan.
* **The Solution**: Guided by Teh Ming En's recommendation, we flipped the creation lifecycle. When a trip is initiated, friends join the trip lobby first via invite link or room code. All joined members independently vote across an interactive 3×3 Vibe Grid (`TripVotingScreen`) covering core travel styles (*Foodie*, *Culture*, *Adventure*, *Chill*, *Hidden Gems*). Only after the group's collective preferences and vibes are aggregated does the AI engine synthesize a cohesive, balanced itinerary tailored to everyone from day one.

#### 2. From Generic Planning Forms to In-Chat Conflict Resolution (Simulation 1)
* **The Problem**: Early designs forced users into separate voting and settings screens whenever group members had conflicting place preferences, fragmenting the conversation.
* **The Solution**: In response to Mah Qing Fung's guidance, conflict resolution was moved entirely inside the collaborative chat feed. When members propose competing activities (e.g., shopping in Harajuku vs. cultural sights at Senso-ji), the Travelyn AI assistant detects the debate, summarizes trade-offs, and injects an inline interactive approval card with real-time voting badges.

#### 3. From Static Schedules to Dynamic In-Trip Replanning (Simulations 2–6)
* **The Problem**: Traditional itineraries break the moment a cafe is closed or a group spends extra time at an attraction.
* **The Solution**: We architected a reactive replanning engine that triggers real-time state adaptations with smooth 3D and insertion animations:
  * **Venue Disruption Swap (`TripCafeClosedSheet`)**: When a scheduled venue is closed, Travelyn suggests an open, highly-rated alternative within walking distance and executes a 3D flip swap on the itinerary timeline.
  * **Schedule Time-Lag Realignment (`TripScheduleSyncSheet`)**: If a group lingers at a spot, Travelyn recalculates downstream durations and offers one-tap timeline synchronization so no scheduled stops are missed.
  * **Spontaneous Detours (`FreeTimeBanner`)**: Free gaps between stops automatically generate curated "Surprise Me" suggestions smoothly inserted into the timeline.

#### 4. From Standard Photo Uploads to Gamified Polaroid Scrapbooks
* **The Problem**: Standard travel apps dump photos into basic grid lists, losing emotional resonance and context.
* **The Solution**: We developed a specialized camera viewfinder (`TripCameraCheckinScreen`) equipped with landmark targeting brackets. Snapping a photo produces a tilted, vintage Polaroid card decorated with customizable washi tape, location geotags, local weather stamps, and a Travelyn postal seal, automatically preserved in the shared `DiaryTab`.

---

### 🧪 In-Trip Simulation Engine (Judge & Evaluator Showcase)

To demonstrate Travelyn's real-time adaptability during pitches and evaluations, we implemented a dedicated **Simulation Events Sheet** (`TripSimulationEventsSheet`) accessible via the **`?`** icon on the trip dashboard:

| # | Simulation Scenario | Event Trigger | System Reaction & Animation | User Experience Outcome |
| :-: | :--- | :--- | :--- | :--- |
| **1** | **Resolve Conflict** | Group disagreement in chat | Activates inline debate moderation & consensus voting sheet (`TripConflictApprovalSheet`) | Resolves disputes amicably in seconds without leaving group chat |
| **2** | **Start Trip** | Day 1 departure | Pops up Morning Briefing (`TripMorningBriefingDialog`) with weather, transit, and active destination | Aligns all members on daily readiness and immediate next stops |
| **3** | **Arrive at First Location** | GPS / Geofence trigger | Launches celebratory arrival screen with cultural tips, specialty dishes, and camera prompt | Prompts seamless transition into landmark check-in |
| **4** | **Surprise Plan** | Spontaneous free gap | Smooth vertical card insertion animation injecting a curated nearby detour into the itinerary | Discovers hidden gems during downtime without breaking main plans |
| **5** | **Cafe Closed** | Venue closure detected | Pops up `TripCafeClosedSheet` and executes a **3D flip swap animation** with an open cafe | Zero panic; instantly replaces closed stop with an open alternative |
| **6** | **Spend Too Much Time** | Itinerary time overrun | Triggers `TripScheduleSyncSheet` with automated downstream timeline recalculation | Synchronizes group schedule with one tap, preventing missed reservations |

---
## Getting Started

### Prerequisites
-   **Flutter SDK**: Version 3.24.0 or higher
-   **Dart SDK**: Version 3.5.0 or higher
-   **Google Chrome** (for web preview) or Android/iOS Emulator
-   **Git** installed on your system

### Installation
1. Clone the repository:
    ```bash
    git clone https://github.com/yaotingchun/Travelyn.git
    cd Travelyn
    ```
2. Install dependencies:
    ```bash
    flutter pub get
    ```

### Environment Setup
This project uses environment variables for Google Cloud Vision, Gemini AI, and Mapbox.

1. **Environment Variables Configuration**:
   - Duplicate `.env.example` to create `.env`:
     ```bash
     cp .env.example .env
     ```
   - Fill in your API keys:
     ```env
     GEMINI_API_KEY=your_gemini_api_key_here
     MAPBOX_ACCESS_TOKEN=your_mapbox_token_here
     ```

2. **Google Service Account Credentials**:
   - Place your service account JSON file under `credentials/google.json` if running direct server-side vision tests.

### Running the Application

#### Option 1: Running Flutter Web (Recommended for Demo)
```bash
flutter run -d chrome
```

#### Option 2: Running on Mobile Devices (iOS / Android)
Ensure your emulator is running or a physical device is connected, then run:
```bash
flutter run
```

#### Option 3: Building Release Web Bundle
```bash
flutter build web --release
```
---
## Future Improvements
-   **Predictive Itinerary Simulation & Smart Auto-Reroute**: Scrub a timeline slider to simulate crowd density, transit delays, and weather forecasts up to 72 hours ahead to automatically reorganize trip schedules.
-   **Offline Vector Maps & Local P2P Sync**: Mesh Bluetooth/local Wi-Fi sync between traveling friends to split expenses and update offline coordinates when roaming without cell service.
-   **Multilingual Real-Time Voice Companion**: Travelyn audio translation and live ambient menu translation powered by Gemini Multimodal Live API.
