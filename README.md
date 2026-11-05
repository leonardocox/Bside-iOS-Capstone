# Bside

## Table of Contents

1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Wireframes](#wireframes)
4. [Project Progress](#project-progress)
5. [Schema](#schema)

## Overview

### Description

Bside is a music journal where you can search for songs and albums, see their artwork, and record what you thought after listening. You can mark a first listen, give a rating, write an optional review, and revisit your entries in your personal journal.

### App Evaluation

- **Category:** Music and personal journaling
- **Mobile:** Bside lets you search for music and record a reaction wherever you listen. Artwork and a quick rating flow make it easy to add an entry on your phone.
- **Story:** Music can become tied to a moment, but it is easy to forget what a first listen felt like. Bside gives those reactions a place to live so you can look back at how your taste grows and show off your music taste.
- **Market:** Bside is for music fans who enjoy discovering songs and albums and want a personal place to rate, review, and remember them.
- **Habit:** Users can return whenever they discover a song or album, then revisit their journal to see what they listened to and how they felt about it.
- **Scope:** The first version focuses on music search, artwork, previews when available, and a saved journal for songs and albums with ratings, first listen status, and optional reviews.

## Product Spec

### 1. User Stories

**Required Must-have Stories**

- [x] A user can search for music and see matching songs and albums with artwork.
- [x] A user can select a song or album to view its details.
- [x] A user can mark whether an entry is a first listen.
- [x] A user can give a song or album a rating in half-star increments and write an optional review.
- [x] A user can save an entry and find it in their personal journal.
- [x] A user's journal entries remain available after closing and reopening the app.

**Optional Nice-to-have Stories**

- [x] A user can play a short song preview when one is available.
- [ ] A user can filter their journal to view songs or albums separately.

### 2. Screen Archetypes

- [x] Discover Screen
  - Users can search for songs and albums and see matching results with artwork.
  - When no search is active, Discover shows a custom Bside wordmark over a gently moving blue glass background.
- [x] Music Detail Screen
  - Users can view artwork, title, and artist information.
  - Albums show their tracks; available songs have preview controls.
- [x] Review Screen
  - Users can mark first listen and liked status, choose a half-star rating, add optional notes, and save.
- [x] Journal Screen
  - Users can revisit saved entries and open a saved review to see its details.

### 3. Navigation

**Tab Navigation**

- Discover opens the Discover Screen.
- Journal opens the Journal Screen.

**Flow Navigation**

- [x] Selecting a Discover search result opens Music Detail.
- [x] Selecting a track from an album opens that track's Music Detail screen.
- [x] Choosing Write Review opens Review for the selected song or album.
- [x] Saving a review returns to Music Detail. The saved entry is available from the Journal tab.
- [x] Selecting an entry in Journal opens its saved review.

## Wireframes

<img src="wireframes.jpg.jpg" width="600" alt="Hand-drawn Bside wireframes">

## Project Progress

### November 5 Unit 9 Progress Checkpoint

The core music journal flow is working. Users can search for songs and albums, open an album and its tracks, play available short previews, and write a review for a selected song or album. A review records first listen and liked status, a rating in half-star increments, and optional written notes. Saved reviews appear in Journal, can be opened again, and remain available after the app is closed and reopened.

I also redesigned the empty Discover screen with a full-screen blue glass image, a custom lowercase Bside wordmark, a translucent search field, and subtle background movement. The wordmark disappears during a search and returns when the search is cleared. I checked that search results and album navigation still work after the design changes.

The next focus is improving the Journal presentation and testing the complete search-to-saved-review flow again before the final polish pass.

[Watch the Unit 9 progress video](https://www.loom.com/share/c1e4cae5e7f34d14ad26135aa098d803)

### October 27 Checkpoint

Discover now shows artwork alongside matching songs and albums. Selecting a result opens Music Detail with its artwork, title, and artist. Opening an album loads its track list, and selecting a track opens that song's detail screen. I tested going back and opening a different album to confirm that its own tracks appear.

At this checkpoint, the next focus was opening Review from Music Detail, recording a rating and listening notes, and saving entries in Journal.

### Unit 8 Submission Checkpoint

Bside ran in the simulator with Discover and Journal tabs. In Discover, a user could search the music catalog and see matching songs and albums in a scrolling list with their titles and artists. Searching again replaced the previous results.

At this checkpoint, Music Detail, Review, and saved Journal entries were still in development. Showing artwork beside each search result was the next design step.

[Watch the Unit 8 progress video](https://www.loom.com/share/835269e31e2246f4b1ce620f44674c5b)

## Schema

### Models

| Model | Purpose | Main properties |
| --- | --- | --- |
| `MusicItem` | Represents a song or album returned by the music catalog | Track and collection IDs, names, artist, artwork URL, preview URL, and item type |
| `MusicReview` | Represents one saved journal entry | Unique ID, selected `MusicItem`, first listen, liked, rating, review text, and creation date |

`MusicReview` and `MusicItem` conform to `Codable`. `ReviewStore` saves and loads the review collection using `UserDefaults`.

### Networking

Bside uses Apple's iTunes catalog through `MusicService`:

- **Discover search:** Requests matching songs and albums from the iTunes Search API.
- **Album detail:** Looks up an album by collection ID and displays its tracks.
- **Artwork:** Loads images from the artwork URLs provided by the catalog.
- **Preview:** Plays an available song preview URL.

Music search and album lookup use `URLSession`. Catalog responses are decoded into `MusicItem` values.
