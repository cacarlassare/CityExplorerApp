##Note: As mentioned in the first interview, due to lack of enough experience working with SwiftUI, I used UIKit for the visuals.


# City Explorer App

Welcome to the **City Explorer App** repository! This iOS application allows users to browse, search, and select cities from a comprehensive list. Once a city is selected, its location is displayed on an interactive map. Users can mark cities as favorites and view detailed information about each city. The app ensures a smooth user experience with robust data management, error handling, and responsive UI design.

## Features

- **City Selection & Search:**
  - Browse a list of cities.
  - Search for cities using the integrated search bar.
  - Mark cities as favorites for quick access.

- **Interactive Map:**
  - View the selected city's location on an `MKMapView`.
  - Interactive annotations with callouts for more information.

- **Detailed City Information:**
  - Access comprehensive details about each city, including name, country, and geographical coordinates.

- **Data Persistence:**
  - Store favorite cities and city data locally using Core Data.
  - Offline access to previously loaded cities.

- **User Experience Enhancements:**
  - Consistent loading indicators during data operations.
  - Centralized error handling with user-friendly alerts.
  - Responsive layout adjustments for portrait and landscape orientations.


## Getting Started

Follow these instructions to set up and run the City Explorer on your local machine.

### Prerequisites

- **Xcode 14.0** or later
- **iOS 14.0** or later
- **Swift 5.5** or later

### Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/cacarlassare/CityExplorerApp.git
   ```

2. **Navigate to the Project Directory:**

   ```bash
   cd CityExplorerApp
   ```

3. **Open the Project in Xcode:**

   ```bash
   open UalaTest.xcodeproj
   ```

4. **Build and Run:**

   - Select the desired simulator or your physical device.
   - Click the **Run** button (▶️) in Xcode to build and launch the app.

## Technologies Used

- **Swift 5.5**
- **UIKit**
- **MapKit**
- **Core Data**
- **MVVM Architecture**
- **Singleton Patterns**
- **Delegation & Protocols**
- **Asynchronous Networking**


## Configuration

### Data Persistence

The app uses Core Data for data persistence.

### Data Source

The app fetches city data from a remote JSON endpoint:

```
https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json
```


This project is licensed under the [MIT License](LICENSE).
