#!/bin/bash

# 1. Create Core Layers
echo "🚀 Creating Core Architecture..."
mkdir -p lib/core/constants
mkdir -p lib/core/theme
mkdir -p lib/core/utils
mkdir -p lib/core/services
mkdir -p lib/core/widgets/buttons
mkdir -p lib/core/widgets/dialogs

# 2. Create Feature Folders based on Project Requirements
echo "📂 Creating Feature Modules..."

# Auth (User Profiles)
mkdir -p lib/features/auth/presentation/screens
mkdir -p lib/features/auth/presentation/widgets
mkdir -p lib/features/auth/data/models
mkdir -p lib/features/auth/data/repositories

# Realtime Booking (Map & Slots)
mkdir -p lib/features/booking/presentation/screens
mkdir -p lib/features/booking/presentation/widgets
mkdir -p lib/features/booking/data/services
mkdir -p lib/features/booking/domain/logic

# Admin Panel (Dashboard)
mkdir -p lib/features/admin_panel/presentation/dashboard
mkdir -p lib/features/admin_panel/presentation/court_management
mkdir -p lib/features/admin_panel/data

# Payment Gateway (PayHere/OnePay)
mkdir -p lib/features/payment/presentation
mkdir -p lib/features/payment/data/gateways

# Matchmaking (Find Opponent/Teams)
mkdir -p lib/features/matchmaking/presentation/screens
mkdir -p lib/features/matchmaking/domain/entities

# Leaderboard & Scoring (70% Verification Logic)
mkdir -p lib/features/competitions/presentation/leaderboard
mkdir -p lib/features/competitions/domain/verification_logic

# Gamification (Badges & Streaks)
mkdir -p lib/features/gamification/presentation/badges
mkdir -p lib/features/gamification/data

# Health Integration (Google Fit)
mkdir -p lib/features/health/data/google_fit_api
mkdir -p lib/features/health/presentation

# AI Chatbot
mkdir -p lib/features/chatbot/presentation/chat_ui
mkdir -p lib/features/chatbot/data/ai_service

# 3. Create placeholder files to keep folders in Git
touch lib/core/constants/app_colors.dart
touch lib/core/services/api_service.dart
touch lib/features/auth/presentation/screens/login_screen.dart
touch lib/features/booking/presentation/screens/map_view.dart
touch lib/features/chatbot/presentation/chat_ui/chat_bubble.dart

echo "✅ CourtConnect Frontend Structure Created Successfully!"