with open("lib/features/leaderboard/ui/screens/screen/leaderboard_screen.dart", "r") as f:
    text = f.read()

import re
# We need to remove ChallengeCardWidget and its state from _LeaderboardScreenState
# and put it at the end of the file.
# The `class ChallengeCardWidget` currently starts at line 511.
# We can find `class ChallengeCardWidget` and `// --- Helper Widget: Player List Items ---`

chunk_start = text.find("  // --- Helper Widget: Challenge Cards ---\n}")
chunk_end = text.find("  // --- Helper Widget: Player List Items ---")

# Extract the classes
classes_text = text[chunk_start + len("  // --- Helper Widget: Challenge Cards ---\n}"):chunk_end]

# Remove the classes from their current position and the wrong brace
new_text = text[:chunk_start] + text[chunk_end:]

# Append the classes to the very end
new_text = new_text + "\n" + classes_text.strip() + "\n"

with open("lib/features/leaderboard/ui/screens/screen/leaderboard_screen.dart", "w") as f:
    f.write(new_text)
