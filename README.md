# Toe Beans

Toe Beans is a passion project I started in summer 2026, inspired by my love of cats and curiosity about how people's preferences can shape a ranking. Users add cats they've interacted with and rank pairs of cats, building personalized rankings within an Elo rating system.

I built this platform to bring together two things I enjoy: creating useful software and finding thoughtful ways to work with data. Every choice is saved as a comparison and updates that user's ratings, keeping the raw preference data distinct from the ranking it produces.

## Features

- Browse and add cat profiles, including photos and shelter details.
- Compare cats head-to-head and build a personal ranking.
- Save favorite cats to a bucket list and add notes.
- Follow friends and browse community activity in the feed.
- Keep user-specific ratings and activity protected with Supabase authentication and Row Level Security.

## Ranking Mechanics

Each user has a separate rating for every cat, starting at 1500 Elo. When a user picks a favorite from a pair, the app calculates the expected outcome from both current ratings, then adjusts both scores using the standard Elo update with a K-factor of 32. Choosing a higher-rated cat changes the scores differently than choosing a lower-rated cat, so the ranking responds to both the result and the prior expectation.

When placing a newly added cat, the app compares it against up to three randomly selected cats the user has already rated. Each comparison is also stored as a separate preference record, so the app retains the choices behind the current scores. Rankings remain personal; a shared catalog can therefore produce different orderings for different users.

## AI-Assisted Development

I used AI as a development partner to explore approaches, implement and refine features, troubleshoot, and improve documentation. I set the direction, reviewed and integrated suggestions, and checked the behavior of the system. Learning to use AI thoughtfully as part of building a working application is one of the things this project represents for me.
