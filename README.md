# Empire Flippers Listings Sync

## Overview

This Rails application imports listings from the Empire Flippers public listings API, stores them in PostgreSQL, and syncs current `For Sale` listings to HubSpot as deals.

The app is designed around a daily sync flow:

- fetch listings from Empire Flippers
- persist or update them locally
- sync eligible listings to HubSpot
- avoid creating duplicate HubSpot deals

## Features

- Daily sync of listings from the Empire Flippers API
- PostgreSQL persistence for imported listings
- HubSpot deal creation for listings with status `For Sale`
- Duplicate prevention using stored HubSpot deal IDs and deal-name lookup
- Background job processing with Sidekiq and `sidekiq-scheduler`

## Tech Stack

- Ruby on Rails 7
- PostgreSQL
- Sidekiq
- sidekiq-scheduler
- HTTParty
- HubSpot API Client
- RSpec

## Setup Instructions

1. Clone the repository:

   ```bash
   git clone https://github.com/pedroreznd/empire_flippers_challenge.git
   cd empire_flippers_challenge
   ```

2. Install dependencies:

   ```bash
   bundle install
   ```

3. Create the database:

   ```bash
   bin/rails db:create
   ```

4. Run migrations:

   ```bash
   bin/rails db:migrate
   ```

## Environment Variables

The application expects the following environment variable:

- `HUBSPOT_ACCESS_TOKEN`

For local development, a `.env` file can be used. Example:

```env
HUBSPOT_ACCESS_TOKEN=your_hubspot_private_app_token
```

## Running the App

Start the Rails server if needed:

```bash
bin/rails server
```

Open a Rails console:

```bash
bin/rails console
```

## Running the Sync Manually

From the Rails console:

```ruby
Listings::Importer.call
Hubspot::DealSyncService.call
DailyListingSyncJob.perform_now
```

## Running Sidekiq

1. Start Redis.
2. Start Sidekiq with the scheduler config:

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

The scheduled job is configured to run once per day at `08:00`.

## Running Tests

```bash
bundle exec rspec
```


<br/>
Built with the assistance of OpenAI Codex CLI and ChatGPT (GPT-5.3 Codex).
