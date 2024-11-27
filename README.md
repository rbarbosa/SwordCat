## Project Overview

This iOS application was developed as part of Sword Health assignment to demonstrate proficiency in iOS development, API integration, and software architecture. The App uses [Cat API](https://thecatapi.com/) and all of its features/behaviour involves the usage of API.
Although it seems a simple project to fetch breed cats, it hides complexity due to keep state consistency locally and with the API that, in this case is used as a backend. Particularly, if we take in account that this backend is suited for getting breeds, images, marking images as favorites, but not prepared to deal with favorite breeds.
The commit history reflects the attempts to achieve to a working, testable solution, but far from ideally.
The app uses the API to:
- Fetch breeds
- Fetch favorite images
- Search breed
- Mark an image as favorite
- Unmark an image as favorite

Key features of this implementation include: 
- Networking to consume Cat API including error handling
- Use of SwiftUI for building the UI, not perfect, but still user-friendly interface
- Implementation of a scalable MVVM architecture
- Comprehensive unit testing with the new Swift Testing framework

## Features


## Technologies Used
- Xcode 16.1
- iOS 18.1
- SwiftUI

## Architecture

This project implements the Mode-View-ViewModel (MVVM) architecture in an opinionated way, i.e. inspired by TCA, complemented by additional abstraction layers for improved scalability and testability.

The core principles of the implementation are:
- View model holds the state
- The state can only be changed through the view model and through a single method - `send(_:)`
- Navigation is modeled through an enum
- Use PointFree's frameworks which helps, and improves, the ergonomics of this architecture, particularly CasePaths, SwiftNavigation

**Additional Layers**

- Repository Layer: Abstracts data sources, providing a clean API for data operations.
- Networking Layer: Manages API interactions, including request construction and response handling.
- Favorites Manager: Manages favorites and serves as proxy to repositories

**Benefits of This Architecture**

- Scalability: The separation of concerns allows for easy expansion of features and data sources.
- Testability: Each component can be tested in isolation, facilitating comprehensive unit testing.
- Maintainability: Clear separation of responsibilities makes the codebase easier to understand and maintain. 
- Simplicity: It's easy to understand and implement new features

**Development Process**

As already mentioned, the development was highly influenced by the understanding of the features pretended and the API capacities.
The first iteration was to understand the API and how to fetch images (without taking into account breeds).
The process to get breeds is, itself, simple. Marking a breed as favorite locally has no science too. Marking them as favorite on the backend...well that's not possible.
What is available is to mark an image as favorite. Ok, we pick the image of the breed and mark it as favorite. Seems easy... but we need to add another piece of information - a user id (`sub_id` on the API).
This is needed because the API allows that within an API-Key it can handle different users.
For the sake of simplicity of the exercise, I created a default user.
But now, when fetching the favorites we need to filter the user that is requesting them.
If the app is launched for the first time ever, there's a clean state, and there are no problems regarding inconsistencies. Meaning, when we fetch the breeds for the first time, we are sure that none of them are favorites.
That's not the case for subsequent launches (unless we never mark an item as favorite).
When we present the items we want to show if it's a favorite or not.
Initially, I did this a three steps process:
1 - Fetch breeds
2 - Fetch favorites 
3 - Match breeds images with favorites (images)

But this is not a great user experience. What we would see is a list being presented, and after a noticeable time a view update with favorites being marked.
Even worst, if while this process is going through, the user could mark an item as favorite which could lead to inconsistencies.

This is the reason behind loading favorites, and then items, when launching the app. Only when this process finishes, the tabs are presented.
Also, what if we do a search and it's presented a breed not yet downloaded? Is it a favorite?
Note that I didn't have the time to handle this situation. I left as comment a few strategies to deal with this situation. For instance, while we don't get the favorites we could disable this functionality on the app.

The second problem arises when showing the tab with the favorites.
In this case, we only have a list of image ids, but not the actually breed.
For each of the image ids we need to fetch individually the image object to get the breed associated. Only after we can show the favorites.
Note that while we might already have some breeds on the breeds tab, we can have favorites that were not yet fetched.
Of course, we could optimize requests by checking which were already and which we need to get. I also didn't have time for this.

Finally, we need to keep consistency between tabs (and detail view) and API.
Since the API is not designed for the purpose of having a favorite breed list, my solution was to keep a local state synced with the API.
That was the goal of Favorites Manager, although the solution is also far from perfect.
Nevertheless, when a view changes the favorite state, besides doing it on the backend through the `FavoritesManager`, it changes the state through the view models to the other views.
For instance, when displaying a detail breed, if we toggle the favorite state the process is:
- Change the state on the API (through `FavoritesManager`)
- When dismissing the view change the current view (or the detail root view) through the view model
- Change the state of the tab not selected

As mentioned, the solution is not ideal, and not scalable for a larger app where this state needs to be known.

**Testing Framework**

The project leverages the new Swift Testing framework, introduced in recent Xcode versions. 
It was my third contact with it, and I've found, once again, this framework offers enhanced capabilities for test organization and execution, contributing to a robust testing strategy.

## Setup and Installation - UPDATED
Since I've exposed the API-KEY, I had to generate a new one and use a config file - `Confif.xcconfig`. To set up the project:
- rename the file `Config.xcconfig.template` to `Config.xcconfig`
- get an API key
- Edit `Config.xcconfig` and replace "your_api_key_here" with the API key
After installing the Xcode, the process should be seamlessly, and the app should run without problems.
Note that since there's a default user, you might get already some favorites set.


## Testing

This project leverages the new Swift Testing framework, introduced in recent Xcode versions, to ensure code reliability and functionality. 
The testing strategy focuses primarily on the models and view models, which form the core of the application's business logic.
I didn't have time to make all the tests I would like.

## Future Improvements

I didn't have the time to implement offline persistence. In this case, would also be challenging. How would we sync offline favoriting with online? Should we disable offline?

