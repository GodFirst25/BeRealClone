# Project 2 - *BeRealClone*

Submitted by: **Olamide Oduntan**

**BeRealClone** is an app that ets users share authentic moments through photos and captions. Featuring user authentication, photo upload from device library, and a social feed displaying posts with user info and timestamps. Built with SwiftUI and Parse backend for secure data storage and real-time content sharing.

Time spent: **12** hours spent in total

## Required Features - Part 1

The following **required** functionality is completed:

- [✅] Users see an app icon in the home screen and a styled launch screen.
- [✅] User can register a new account
- [✅] User can log in with newly created account
- [✅] App has a feed of posts when user logs in
- [✅] User can upload a new post which takes in a picture from photo library and an optional caption	
- [✅] User is able to logout	
 
The following **optional** features are implemented:

- [ ] Users can pull to refresh their feed and see a loading indicator
- [ ] Users can infinite-scroll in their feed to see past the 10 most recent photos
- [ ] Users can see location and time of photo upload in the feed	
- [ ] User stays logged in when app is closed and open again	


The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

## Video Walkthrough
https://www.loom.com/share/5ca2ed319d5e40278cd06dc8ba73c542
 

## Notes

Building the BeRealClone app presented several key challenges including Parse/Back4App integration issues with file upload restrictions (solved through image compression and proper naming), iOS 15.6 compatibility limitations that prevented using modern SwiftUI TextField features, UIImagePickerController dismiss logic problems where the "Choose" button initially failed to work, implementing a two-step upload process for data integrity, managing authentication state across app launches, ensuring proper feed refresh after post creation, and debugging Parse response decoding errors where imageFile was stored incorrectly. These challenges required implementing proper error handling, console logging, and workarounds for platform limitations while maintaining a smooth user experience.


## Required Features - Part 2

The following **required** functionality is completed:

- [ ] User can launch camera to take photo instead of photo library
  - [ ] Users without iPhones to demo this feature can manually add unique photos to their simulator's Photos app
- [ ] Users are not able to see other users’ photos until they upload their own.
- [ ] Users can intereact with posts via comments, comments will have user data such as username and name
- [ ] Posts have a time and location attached to them
- [ ] Users are not able to see other photos until they post their own (within 24 hours)	
 
The following **optional** features are implemented:

- [ ] User receive notifcation when it is time to post

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

## Video Walkthrough

Here is a reminder on how to embed Loom videos on GitHub. Feel free to remove this reminder once you upload your README. 

[Guide]](https://www.youtube.com/watch?v=GA92eKlYio4) .

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
