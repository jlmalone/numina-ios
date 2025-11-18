# TASK: Add Reviews UI to Numina iOS App

> **IMPORTANT**: Check for `.task-reviews-ui-completed` before starting.
> **When finished**, create `.task-reviews-ui-completed` file.

## 🎯 OBJECTIVE

Build UI for reading and writing class/trainer reviews with SwiftUI.

## 📋 REQUIREMENTS

### Features
1. **View Reviews**
   - Reviews list on class detail
   - Star ratings
   - Pros/cons
   - Photos
   - Helpful voting
   - Sort options

2. **Write Review**
   - Rate class (1-5 stars)
   - Review form
   - Add pros/cons
   - Photo picker
   - Submit

3. **My Reviews**
   - List my reviews
   - Edit/delete

4. **Pending Reviews**
   - Classes to review
   - Quick prompts

### Files
- `ReviewsListView.swift` - View reviews
- `WriteReviewView.swift` - Write review
- `MyReviewsView.swift` - User's reviews
- `PendingReviewsView.swift` - Classes to review
- `ReviewRow.swift` - Review card
- `StarRatingView.swift` - Star rating input/display
- `ReviewsViewModel.swift`
- `WriteReviewViewModel.swift`
- `MyReviewsViewModel.swift`

### API Integration
- `POST /api/v1/reviews/classes/{classId}`
- `GET /api/v1/reviews/classes/{classId}`
- `PUT /api/v1/reviews/{reviewId}`
- `DELETE /api/v1/reviews/{reviewId}`
- `POST /api/v1/reviews/{reviewId}/helpful`
- `GET /api/v1/reviews/my-reviews`
- `GET /api/v1/reviews/pending`

### Local Storage
- SwiftData for reviews
- Draft storage

## ✅ ACCEPTANCE CRITERIA

- [ ] Read reviews on class pages
- [ ] Star rating works
- [ ] Review submission successful
- [ ] Photos upload
- [ ] Helpful voting works
- [ ] Edit/delete own reviews
- [ ] Dark mode supported

## 📝 DELIVERABLES

- Review views
- ViewModels
- SwiftData models
- Photo handling
- Navigation
- Tests

## 🚀 COMPLETION

1. Build in Xcode
2. Test
3. Create `.task-reviews-ui-completed`
4. Commit: "Add reviews UI with photo uploads"
5. Push: `git push -u origin claude/add-reviews-ui`

---

**Est. Time**: 60-75 min | **Priority**: MEDIUM
