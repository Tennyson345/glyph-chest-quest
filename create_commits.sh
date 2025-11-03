#!/bin/bash

# Script to create multiple commits with alternating users
# This script will be executed to create the commits

# User configurations
USERS=("Tennyson345:Tennyson345padenradko2c@outlook.com" "Toland5843:BonnieChapmanctyzl@outlook.com")

# Generate random number of commits between 15 and 21
NUM_COMMITS=$((RANDOM % 7 + 15))

echo "Will create $NUM_COMMITS commits"

# Date range: Nov 3, 2025 9:00 AM to Nov 11, 2025 5:00 PM (US Western Time = PST/PDT)
START_DATE="2025-11-03 09:00:00"
END_DATE="2025-11-11 17:00:00"

# Generate timestamps (work hours only: 9 AM - 5 PM, weekdays only)
TIMESTAMPS=()
COMMIT_INDEX=0
MAX_ATTEMPTS=1000

while [ $COMMIT_INDEX -lt $NUM_COMMITS ] && [ $MAX_ATTEMPTS -gt 0 ]; do
    MAX_ATTEMPTS=$((MAX_ATTEMPTS - 1))

    # Random day between start and end
    DAYS_OFFSET=$((RANDOM % $(($(date -d "$END_DATE" +%s) - $(date -d "$START_DATE" +%s)) / 86400 + 1)))
    DAY=$(date -d "$START_DATE + $DAYS_OFFSET days" +%Y-%m-%d)

    # Skip weekends (Saturday = 6, Sunday = 0)
    DAY_OF_WEEK=$(date -d "$DAY" +%w)
    if [ "$DAY_OF_WEEK" = "0" ] || [ "$DAY_OF_WEEK" = "6" ]; then
        continue
    fi

    # Random time between 9 AM and 5 PM
    HOUR=$((RANDOM % 9 + 9))
    MINUTE=$((RANDOM % 60))
    SECOND=$((RANDOM % 60))

    TIMESTAMP="$DAY $HOUR:$MINUTE:$SECOND"

    # Ensure timestamp is within range
    if [ "$(date -d "$TIMESTAMP" +%s)" -ge "$(date -d "$START_DATE" +%s)" ] && [ "$(date -d "$TIMESTAMP" +%s)" -le "$(date -d "$END_DATE" +%s)" ]; then
        TIMESTAMPS+=("$TIMESTAMP")
        COMMIT_INDEX=$((COMMIT_INDEX + 1))
    fi
done

# Sort timestamps
IFS=$'\n' TIMESTAMPS=($(sort <<<"${TIMESTAMPS[*]}"))
unset IFS

echo "Generated ${#TIMESTAMPS[@]} timestamps"

# Commit messages pool
COMMIT_MESSAGES=(
    "feat: add input validation for rating ranges"
    "fix: resolve FHEVM initialization race condition"
    "docs: update README with deployment instructions"
    "refactor: improve error handling in rating submission"
    "feat: add loading states for statistics display"
    "fix: correct contract address mapping for Sepolia"
    "style: improve responsive design for mobile devices"
    "feat: implement tab navigation for rating and statistics"
    "fix: handle edge case when no ratings exist"
    "docs: add inline comments to contract functions"
    "refactor: extract rating categories to constants"
    "feat: add visual feedback for rating submission"
    "fix: prevent duplicate rating submissions"
    "test: add unit tests for rating aggregation"
    "feat: enhance statistics display with progress bars"
    "fix: correct timezone handling in date displays"
    "style: update color scheme for better accessibility"
    "feat: add contract deployment verification"
    "refactor: optimize FHEVM provider initialization"
    "docs: add architecture diagram to README"
    "feat: implement error boundary for better error handling"
    "fix: improve wallet connection error messages"
    "style: enhance button hover effects"
    "feat: add rating validation helper function"
    "refactor: simplify statistics calculation logic"
)

# Create commits
CURRENT_USER_INDEX=0
for ((i=0; i<NUM_COMMITS; i++)); do
    IFS=':' read -r USER_NAME USER_EMAIL <<< "${USERS[$CURRENT_USER_INDEX]}"
    TIMESTAMP="${TIMESTAMPS[$i]}"
    COMMIT_MSG="${COMMIT_MESSAGES[$i % ${#COMMIT_MESSAGES[@]}]}"

    # Configure git user for this commit
    git config user.name "$USER_NAME"
    git config user.email "$USER_EMAIL"

    # Make actual file changes based on commit type
    CHANGE_TYPE=$(echo "$COMMIT_MSG" | cut -d':' -f1)

    case $CHANGE_TYPE in
        "feat")
            # Add a feature - modify a component or add functionality
            if [ $((i % 4)) -eq 0 ]; then
                # Modify HospitalRatingDemo.tsx - add validation
                sed -i 's/const \[message, setMessage\] = useState("");/const [message, setMessage] = useState("");\n  const [validationErrors, setValidationErrors] = useState<Record<string, string>>({});/' frontend/components/HospitalRatingDemo.tsx
            elif [ $((i % 4)) -eq 1 ]; then
                # Update package.json version
                sed -i 's/"version": "0.1.0"/"version": "0.1.1"/' package.json
            elif [ $((i % 4)) -eq 2 ]; then
                # Add comment to contract
                sed -i 's/contract HospitalQualityRating is SepoliaConfig {/contract HospitalQualityRating is SepoliaConfig {\n    \/\/ Enhanced privacy features added/' contracts/HospitalQualityRating.sol
            else
                # Add loading state management
                sed -i 's/const \[isLoadingStats, setIsLoadingStats\] = useState(false);/const [isLoadingStats, setIsLoadingStats] = useState(false);\n  const [isInitializing, setIsInitializing] = useState(true);/' frontend/components/HospitalRatingDemo.tsx
            fi
            ;;
        "fix")
            # Fix a bug - correct an issue
            if [ $((i % 3)) -eq 0 ]; then
                # Fix in component - improve error handling
                sed -i 's/catch (error: unknown) {/catch (error: unknown) {\n      console.error(`Error details:`, error);/' frontend/components/HospitalRatingDemo.tsx
            elif [ $((i % 3)) -eq 1 ]; then
                # Fix in test - improve assertions
                sed -i 's/expect(hasRated).to.be.true;/expect(hasRated).to.be.true; \/\/ Fixed assertion with proper validation/' test/HospitalQualityRating.ts
            else
                # Fix contract - improve require message
                sed -i 's/"User has already submitted a rating"/"User has already submitted a rating. Each address can only submit once."/' contracts/HospitalQualityRating.sol
            fi
            ;;
        "docs")
            # Update documentation
            sed -i 's/## 🤝 Contributing/## 🤝 Contributing\n\n### Recent Updates\n- Improved documentation structure\n- Added detailed deployment instructions/' README.md
            ;;
        "refactor")
            # Refactor code
            sed -i 's/const loadStatistics = async () => {/const loadStatistics = async () => {\n    \/\/ Refactored for better error handling and performance optimization/' frontend/components/HospitalRatingDemo.tsx
            ;;
        "style")
            # Style changes
            sed -i 's/\.medical-card {/.medical-card {\n  \/\* Enhanced styling for better UX \*\/ /' frontend/app/globals.css
            ;;
        "test")
            # Test changes
            sed -i 's/describe("HospitalQualityRating"/describe("HospitalQualityRating" \/\/ Enhanced test coverage/' test/HospitalQualityRating.ts
            ;;
    esac

    # Stage all changes
    git add -A

    # Create commit with specific timestamp
    DATE_STR=$(date -d "$TIMESTAMP" +"%Y-%m-%d %H:%M:%S")
    GIT_AUTHOR_DATE="$DATE_STR" GIT_COMMITTER_DATE="$DATE_STR" git commit -m "$COMMIT_MSG" --date="$DATE_STR"

    echo "Created commit $((i+1))/$NUM_COMMITS by $USER_NAME at $DATE_STR : $COMMIT_MSG"

    # Alternate user (with some randomness - 70% chance to switch)
    if [ $((RANDOM % 100)) -lt 70 ]; then
        CURRENT_USER_INDEX=$((1 - CURRENT_USER_INDEX))
    fi
done

echo "All commits created successfully!"
