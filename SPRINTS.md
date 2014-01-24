# SpotHopper - iOS Sprint History
------------------------------

## Sprint 1 - 12/30/13 to 1/10/14
**FOCUS: Initial project, designing archicture/flow, reusable components**
- Created Xcode project
- Set up view archictured
    - Going to break each section of the app into its own Storyboard
    - Made resuable components: footer, slider, sidebar, dropdowns
- Slide PSDs
- Main storyboard
    - Launch view
        - Login with Facebook
        - Login with Twitter
        - Login with SpotHopper account
        - Create SpotHopper account
    - Home view
        - Buttons for spots, drinks, specials, add review
    - Sidebar view
        - Buttons for navigation
- Review storyboard
    - Review menu view
        - Two buttons for navigation
    - View my reviews view
        - Listed user's reviews and has options for filter and sorting
    - Add new review
        - Showed dropdown to select review type


## Sprint 2 - 1/13/14 - 1/24/14
**FOCUS: Data models for API communication, unit tests for parsing of responses into models**
- Models
    - Drink
    - Error
    - Review
    - Slider
    - SliderTemplate
    - Spot
    - User
- Unit tests - (parsing of responses for)
    - Drink
    - Error
    - Review
    - Slider
    - SliderTemplate
    - Spot
    - User
- Rakefile automation
    - Run unit tests with `rake test` 
    - Build app with `rake build version=0.0.1 b=1`
    - Send to TestFlight with `rake build:testflight version=0.0.1 b=1`
- UI Improvements
    - Add new reviews search
        - Searches spots and drinks to create a review on
    - New reviews view
        - Custom forms for spot, beer, cocktail, wine 
- API Interaction
    - Users/Sessions
        - Login with Facebook, Twitter, SpotHopper
        - Create with Facebook, Twitter, SpotHopper
    - Drinks
        - Get/search
    - Spots
        - Get/search
    - Reviews
        - Create
        - Update
        - Get user's reviews
        - 

## Sprint 3 - 1/27/14 - 2/7/14
**FOCUS: Creating new spots and drinks for reviews, saving of unsubmitted reviews locally, show basic (required) sliders and advanced (optional) sliders**
