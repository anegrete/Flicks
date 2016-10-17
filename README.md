# Project 1 - Flicks

Flicks is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: 28 hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] User can view a list of movies currently playing in theaters. Poster images load asynchronously.
- [x] User can view movie details by tapping on a cell.
- [x] User sees loading state while waiting for the API.
- [x] User sees an error message when there is a network error.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] Add a tab bar for **Now Playing** and **Top Rated** movies.
- [x] Implement segmented control to switch between list view and grid view.
- [x] Add a search bar.
- [x] All images fade in.
- [x] For the large poster, load the low-res image first, switch to high-res when complete.
- [x] Customize the highlight and selection effect of the cell. Added scale effect for List view items and rotation effect for Grid view items.
- [x] Customize the navigation bar. The navigation bar displays the search bar in order to have the Search feature over all the different views List/Grid - Now Playing/Top Rated. The 'Back' title was removed from the backBarButtonItem.

The following **additional** features are implemented:

- [x] Customize the status bar style.
- [x] User can view on detail screen more info: formatted release date, vote average and vote count.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Video Walkthrough](Flicks-anegrete.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

This version only works in Portrait orientation.
I tested using iPhone 7 and 6S. I did not spend time with other screen sizes.

Icons by http://iconmonstr.com/

Used libraries (using CocoaPods):
[AFNetworking](https://github.com/AFNetworking/AFNetworking) - A delightful networking framework for iOS, OS X, watchOS, and tvOS. 
[MBProgressHUD](https://github.com/matej/MBProgressHUD) - MBProgressHUD, an iOS activity indicator view

Demo Notes:
- Added a perform selector after delay (to hide the hud after 0.5s) just to be able to show the "updating movies" message in the demo.
- The images requested for the table view and collection view are the original sizes (biggest size), in order to see the 0.3s fade in 
(with the smaller ones it was too fast)

## License

Copyright 2016 Alejandra Negrete

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
