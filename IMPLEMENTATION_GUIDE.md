# Queez App Enhancement - Implementation Tasks

## Project Goal

Enhance the Queez quiz application with:
1. User statistics API on backend
2. Home page dashboard showing user stats
3. Settings page with theme switcher and account options
4. Complete dark mode support
5. Password change feature
6. Fixed bottom navigation button alignment

---

## BACKEND TASKS

### Task B1: Create User Statistics Endpoint

**Location**: Backend user routes file

**What to build:**
- Add a new API endpoint that accepts a user ID
- The endpoint should count how many quizzes the user created
- Count how many quizzes the user has taken/attempted
- Find the user's best quiz score (as a percentage)
- Return all three statistics in JSON format
- If any errors occur, return zeros instead of failing

**How to test:**
- Start the backend server
- Use a HTTP client to call the endpoint with a test user ID
- Verify you get back the three statistics

---

## FLUTTER TASKS - DARK MODE SYSTEM

### Task F1: Define Dark Mode Colors

**Location**: App colors utility file

**What to do:**
- Create a new set of color definitions for dark mode
- Use very dark backgrounds (almost black)
- Use slightly lighter colors for elevated surfaces
- Keep the green accent color (it looks good on dark)
- Use light gray for text instead of dark text
- Create a divider color that's subtle on dark backgrounds

### Task F2: Create Theme Configuration

**Location**: New theme utility file

**What to do:**
- Create a theme class that holds light and dark themes
- Configure light theme using existing app colors
- Configure dark theme using the new dark colors
- Set up all theme properties: backgrounds, text, cards, icons, app bar

### Task F3: Create Theme State Manager

**Location**: New theme provider file

**What to do:**
- Create a provider to manage theme mode (light vs dark)
- When app starts, load saved theme preference from phone storage
- Add a method to toggle between light and dark themes
- When toggling, save the preference to phone storage
- Provide a way to check if dark mode is currently active

### Task F4: Connect Theme to App

**Location**: Main app file

**What to do:**
- Make the app aware of the theme provider
- Watch for theme changes
- Apply light theme when in light mode
- Apply dark theme when in dark mode
- Let the system automatically switch when theme changes

---

## FLUTTER TASKS - HOME PAGE

### Task F5: Create API Service for User Stats

**Location**: New user service file

**What to do:**
- Create a service class to call the backend
- Define the backend API base URL
- Add a method to fetch user statistics from the backend
- Parse the response and return the data
- If the request fails, return zeros for all stats

### Task F6: Build Home Page Screen

**Location**: New home page file

**What to do:**
- Create the main home page screen
- Add variables to store user name and statistics
- When page loads, fetch the user's name from Firebase database
- Call the API service to get user statistics
- Display a welcome header with user's name and today's date
- Show four statistic cards in a grid:
  - Number of quizzes created
  - Number of quizzes completed
  - Best score percentage
  - Overall accuracy
- Add three quick action buttons:
  - Create quiz (goes to create page)
  - Browse library (goes to library page)
  - Join live session (opens a dialog)
- Make the page refreshable by pulling down
- Use appropriate colors for light and dark modes
- Show loading indicator while data is fetching

---

## FLUTTER TASKS - SETTINGS PAGE

### Task F7: Build Settings Page Screen

**Location**: New settings page file

**What to do:**
- Create the main settings page screen
- Load push notification preference from phone storage when page opens
- Organize settings into sections:

**Account Section:**
- Add option to view user profile (navigates to profile page)
- Add option to change password (opens password dialog)

**Preferences Section:**
- Add dark mode toggle switch (connects to theme provider)

**Notifications Section:**
- Add push notifications toggle switch (saves to phone storage)

**About Section:**
- Show app version number
- Add links for terms of service
- Add links for privacy policy  
- Add option to share the app

**Sign Out:**
- Add a red sign-out button at the bottom
- When clicked, clear all saved login data
- Sign out from Firebase
- Return user to login screen

### Task F8: Build Password Change Dialog

**Location**: Same file as settings page

**What to do:**
- Create a pop-up dialog for changing password
- Add three password input fields:
  - Current password
  - New password
  - Confirm new password
- Add validation:
  - Check new passwords match
  - Check new password is at least 6 characters
- When user submits:
  - Verify current password is correct (re-authenticate)
  - Update password in Firebase
  - Send email verification
  - Show success message
- Handle common errors:
  - Wrong current password
  - Weak password
  - Network issues

---

## FLUTTER TASKS - NAVIGATION FIX

### Task F9: Fix Center Button Position

**Location**: Navigation button location file

**What to do:**
- Find the button positioning logic
- Remove any hardcoded offset calculations
- Use the device's safe area measurements instead
- Position button so it's horizontally centered
- Position button so half of it sits in the curved notch of bottom bar
- This should automatically work on all phone sizes

### Task F10: Connect New Pages to Navigation

**Location**: Bottom navigation controller file

**What to do:**
- Remove the temporary home page placeholder
- Replace it with the real home page
- Remove the temporary settings page placeholder
- Replace it with the real settings page
- Remove the method that calculates button offset dynamically
- Use the fixed button position instead
- Import the new home and settings pages

---

## TESTING REQUIREMENTS

### Backend Testing
1. Start backend server
2. Test the stats endpoint with a real user ID
3. Verify response contains all three statistics
4. Test with a user who has no quizzes (should return zeros)

### Dark Mode Testing
1. Open app and navigate to settings
2. Turn on dark mode
3. Visit every page in the app (home, library, create, profile, settings)
4. Verify all pages look correct in dark mode
5. Close app completely and reopen
6. Verify app remembers dark mode setting
7. Turn off dark mode
8. Verify all pages look correct in light mode

### Home Page Testing
1. Open home page
2. Check user name displays correctly
3. Check current date displays correctly
4. Verify statistics show real numbers (not zeros if user has data)
5. Click "Create Quiz" button, verify it goes to create page
6. Click "Browse Library" button, verify it goes to library page
7. Click "Join Live Session" button, verify dialog appears
8. Pull down on the page, verify it refreshes

### Settings Page Testing
1. Open settings page
2. Click "View Profile", verify it navigates to profile
3. Toggle dark mode switch, verify theme changes
4. Toggle push notifications switch
5. Close and reopen app, verify notification setting saved
6. Click sign out, verify it logs out and returns to login

### Password Change Testing
1. Open settings, click "Change Password"
2. Try with wrong current password (should fail)
3. Try with non-matching new passwords (should fail)
4. Try with password less than 6 characters (should fail)
5. Try with correct current password and valid new password
6. Verify success message appears
7. Check email for verification message
8. Try logging in with new password to confirm it worked

### Button Position Testing
1. Test on a small phone
2. Test on a medium phone
3. Test on a large phone
4. Test on a tablet (if available)
5. For each device:
   - Check button is centered horizontally
   - Check button sits properly in the notch
   - Test in portrait mode
   - Test in landscape mode
   - Verify button doesn't overlap navigation items

---

## REQUIRED PACKAGES

Add these to your Flutter dependencies if not already present:
- HTTP package for making API calls
- Internationalization package for date formatting
- Firebase Authentication package
- Cloud Firestore package
- Shared Preferences package for storage
- Riverpod package for state management

Run the package installation command after adding.

---

## KEY POINTS TO REMEMBER

### Backend
- Handle missing data gracefully
- Always use async operations for database
- Don't crash if user has no data

### Dark Mode
- Use near-black backgrounds, not pure black
- Keep green accent color across both themes
- Save theme preference so it persists

### Password Change
- This feature is free in Firebase
- Always re-authenticate before changing password
- Sending verification email is good practice

### Button Position
- Don't use hardcoded numbers
- Use device measurements instead
- Should work on all screen sizes automatically

### Home Page
- Fetch real data from backend
- Don't hardcode statistics
- Handle loading and error states

---

## COMPLETION CHECKLIST

Backend:
- [ ] Stats endpoint created
- [ ] Endpoint tested and working
- [ ] Returns correct data format

Dark Mode:
- [ ] Dark colors defined
- [ ] Theme configuration created
- [ ] Theme provider implemented
- [ ] Main app connected to theme
- [ ] All pages work in dark mode
- [ ] Theme preference saves and loads

Home Page:
- [ ] API service created
- [ ] Home page UI built
- [ ] Stats load from backend
- [ ] Quick actions work
- [ ] Pull-to-refresh works
- [ ] Works in light and dark mode

Settings:
- [ ] Settings page built
- [ ] All sections implemented
- [ ] Dark mode toggle works
- [ ] Notification preference saves
- [ ] Sign out works
- [ ] Password change dialog built
- [ ] Password change works

Navigation:
- [ ] Button position fixed
- [ ] Home page connected
- [ ] Settings page connected
- [ ] Works on all device sizes tested

---

## TROUBLESHOOTING GUIDE

**Statistics show zero:**
- Backend server might not be running
- API URL might be wrong
- User ID might not match database
- Check backend error logs

**Dark mode doesn't save:**
- Check storage permissions
- Try clearing app data and retrying
- Verify storage key names match

**Button misaligned:**
- Make sure all hardcoded offsets removed
- Test on real device, not just simulator
- Check dynamic offset method was deleted

**Password change fails:**
- User must be logged in
- Firebase must be initialized
- Email/password auth must be enabled in Firebase console
- Check internet connection

---

End of Implementation Guide
