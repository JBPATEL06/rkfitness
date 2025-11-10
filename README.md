# RK Fitness App

A modern fitness tracking application built with Flutter.

## Features
- User profile management
- Workout tracking and scheduling
- Progress monitoring
- Custom workout durations
- Responsive UI for all devices
- Smooth performance and fast data fetching

## Recent Improvements

### Problem #2: Code Quality Improvements
#### Changes Made
1. **Code Organization**
   - Separated business logic from UI components
   - Moved service calls to dedicated provider classes
   - Standardized file naming and code structure

2. **Error Handling**
   - Implemented consistent error handling across the app
   - Added user-friendly error messages
   - Introduced loading states for better UX

3. **Code Duplication**
   - Eliminated redundant code in user management
   - Consolidated workout handling logic
   - Standardized common UI patterns

#### Benefits
- **Maintainability**: Easier to understand and modify code
- **Reliability**: Fewer bugs due to consistent error handling
- **Performance**: Reduced code size and better resource usage
- **Scalability**: Easier to add new features
- **Testing**: Code is more testable with separated concerns

### Problem #3: State Management Improvements
#### Changes Made
1. **Provider Implementation**
   - Created dedicated providers:
     - `UserProvider`: Manages user state and authentication
     - `WorkoutProvider`: Handles workout data and operations
     - `NotificationProvider`: Manages app notifications
     - `ProgressProvider`: Tracks workout progress
     - `ScheduleProvider`: Handles workout scheduling

2. **Component Updates**
   - Updated `ProfilePage` to use UserProvider
   - Converted `EditProfile` to use centralized state
   - Enhanced `WorkoutPage` with provider integration
   - Improved `FullWorkoutPage` with proper state management

3. **Data Flow Optimization**
   - Implemented proper data caching
   - Added state persistence where needed
   - Optimized rebuild cycles

#### Benefits of State Management
1. **Performance Improvements**
   - Reduced unnecessary rebuilds
   - Optimized data fetching
   - Better memory management
   - Faster UI updates

2. **Better User Experience**
   - Consistent app state
   - Smoother transitions
   - Improved error handling
   - Real-time updates

3. **Development Benefits**
   - Easier debugging
   - Cleaner code structure
   - Better state tracking
   - Simplified testing

4. **Maintenance Advantages**
   - Clear data flow
   - Isolated state changes
   - Easy to extend functionality
   - Better error tracing

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Update Supabase credentials in `lib/main.dart`
4. Run the app:
   ```bash
   flutter run
   ```

## Technical Requirements
- Flutter SDK
- Dart SDK
- Supabase account
- VS Code or Android Studio

## Providers vs Services

### Providers
Providers are responsible for state management and business logic. They act as an intermediate layer between UI and services.

#### UserProvider
- **Purpose**: Manages user-related state and operations
- **Responsibilities**:
  - Stores current user data in memory
  - Handles user authentication state
  - Manages loading and error states
  - Notifies UI of user data changes
  - Caches user information
- **Benefits**:
  - Prevents duplicate API calls
  - Maintains consistent user state
  - Centralizes user-related logic

#### WorkoutProvider
- **Purpose**: Manages workout data and state
- **Responsibilities**:
  - Caches workout lists by category
  - Handles workout filtering and sorting
  - Manages workout loading states
  - Updates workout data in real-time
- **Benefits**:
  - Optimized workout data loading
  - Reduced API calls through caching
  - Consistent workout state across screens

#### ProgressProvider
- **Purpose**: Handles workout progress tracking
- **Responsibilities**:
  - Tracks ongoing workout progress
  - Stores completion statistics
  - Manages progress history
  - Handles progress updates
- **Benefits**:
  - Real-time progress updates
  - Consistent progress tracking
  - Optimized data persistence

#### ScheduleProvider
- **Purpose**: Manages workout scheduling
- **Responsibilities**:
  - Handles workout scheduling logic
  - Manages schedule conflicts
  - Stores schedule customizations
  - Updates schedule in real-time
- **Benefits**:
  - Centralized schedule management
  - Consistent schedule state
  - Optimized schedule updates

#### NotificationProvider
- **Purpose**: Manages app notifications
- **Responsibilities**:
  - Handles notification state
  - Manages notification preferences
  - Controls notification display
- **Benefits**:
  - Centralized notification management
  - Consistent notification handling
  - Optimized user alerts

### Services
Services handle direct communication with external systems and data sources.

#### UserService
- **Purpose**: Handles user data operations with Supabase
- **Responsibilities**:
  - CRUD operations for user data
  - Direct database interactions
  - Raw data transformations
- **Difference from Provider**:
  - No state management
  - No caching
  - Pure data operations

#### WorkoutService
- **Purpose**: Manages workout data in Supabase
- **Responsibilities**:
  - CRUD operations for workouts
  - Raw workout data handling
  - Database queries
- **Difference from Provider**:
  - No state maintenance
  - Direct database access
  - No UI notifications

#### ProgressService
- **Purpose**: Handles progress data in database
- **Responsibilities**:
  - Stores progress records
  - Retrieves progress history
  - Raw progress data operations
- **Difference from Provider**:
  - No progress tracking state
  - Pure data persistence
  - No real-time updates

### Key Differences
1. **State Management**:
   - Providers: Maintain state, notify UI of changes
   - Services: No state, pure data operations

2. **Caching**:
   - Providers: Cache data, optimize performance
   - Services: No caching, direct database access

3. **UI Integration**:
   - Providers: Direct UI integration with ChangeNotifier
   - Services: No UI awareness or integration

4. **Business Logic**:
   - Providers: Contains business logic and validation
   - Services: Contains only data access logic

5. **Dependency**:
   - Providers: Depend on services
   - Services: Independent, no provider knowledge

## Project Structure
```
lib/
  ├── models/         # Data models
  ├── providers/      # State management
  ├── pages/         # UI screens
  ├── widgets/       # Reusable components
  ├── theme/         # App theme
  ├── utils/         # Utilities
  └── supabaseMaster/ # Backend services
```

## Contributing
Please read our contributing guidelines before making changes to the project.

## Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
