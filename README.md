# FinoTrack 💰

A beautiful personal finance tracker built with Flutter. Track your spending, analyse categories, manage budgets, and chat with an AI assistant that knows your actual transactions.

## Features

- **Spend Summary** — Monthly overview with category breakdown and recent transactions
- **Transactions** — Full list with live search, filter by type, and sort by date/amount
- **Budget** — Category budgets with progress tracking
- **Insights** — Spending trends and analytics
- **AI Chat** — Powered by Cerebras, context-aware answers using your real transaction data
- **Dark / Light mode** — Toggle from the home screen

## Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/skylestial/FinoTrack.git
cd FinoTrack
```

### 2. Set up your API key
```bash
cp .env.example .env
```
Then open `.env` and paste your Cerebras API key:
```
AI_API_KEY=your_cerebras_api_key_here
```
Get a free key at [cloud.cerebras.ai](https://cloud.cerebras.ai)

### 3. Install packages
```bash
flutter pub get
```

### 4. Run
```bash
flutter run
```

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | flutter_bloc |
| AI Backend | Cerebras (`gpt-oss-120b`) |
| Environment | flutter_dotenv |
| Fonts | Google Fonts |

## Project Structure

```
lib/
├── blocs/        # BLoC state management
├── data/         # Mock data
├── models/       # Data models
├── screens/      # All screens
├── theme/        # App theme
├── utils/        # Helpers & constants
└── widgets/      # Reusable UI components
```

## Built with AI Assistance

This project was built using GitHub Copilot as a development accelerator — not as a replacement for thinking.

The architecture decisions (BLoC pattern, screen structure, data flow), the overall design system, and the feature set were all planned and directed by me. Copilot was used strategically to speed up the parts of development that are mechanical by nature — things like scaffolding widget boilerplate, wiring up repetitive event handlers, and generating mock data structures that would otherwise be tedious to write by hand.

Where Copilot really paid off was in the AI chat integration. Rather than spending time reading through API docs and trial-and-erroring the request format, I used it to get the Cerebras OpenAI-compatible call right quickly — then tuned the system prompt myself to get the tone and context injection working the way I wanted.

The real decisions — how the BLoC state flows, how category filtering works, how the add-transaction form feeds back into the live list, how the AI receives financial context — those required understanding the codebase and making deliberate choices. Copilot helped me move faster on execution, but the design was mine.

## Notes

- The `.env` file is **gitignored** — never commit your API key
- All transaction data is currently mocked; new transactions added in-session are stored in BLoC state (not persisted)
