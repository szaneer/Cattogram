# Project 4 - *Cattogram*

**Cattogram** is a Catto photo sharing app using Firebase Cloud Firestore as its backend.

Time spent: **40** hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] User can sign up to create a new account using Parse authentication (+1pt)
- [x] User can log in and log out of his or her account (+1pt)
- [x] The current signed in user is persisted across app restarts (+1pt)
- [x] User can take a photo, add a caption, and post it to "Instagram" (+2pt)
- [x] User can view the last 20 posts submitted to "Instagram" (+2pt)
- [x] User can pull to refresh the last 20 posts submitted to "Instagram" (+1pt)
- [x] User can tap a post to view post details, including timestamp and caption (+2pt)

The following **optional** features are implemented:

- [x] Style the login page to look like the real Instagram login page (+1pt)
- [x] Style the feed to look like the real Instagram feed (+1pt)
- [x] User can use a tab bar to switch between all "Instagram" posts and posts published only by the user. AKA, tabs for Home Feed and Profile (+2pt)
- [x] Add a custom camera using the CameraManager library (+1pt)
- [x] User can load more posts once he or she reaches the bottom of the feed using infinite scrolling (+2pt)
- [x] Show the username and creation time for each post using section headers (+1pt)
   - If you use TableView Section Headers to display the the username and creation time, you'll get "sticky headers" similar to the actual Instagram app.
- [x] After the user submits a new post, show a progress HUD while the post is being uploaded to Parse (+1pt)
- User Profiles:
   - [x] Allow the logged in user to add a profile photo (+2pt)
   - [x] Display the profile photo with each post (+1pt)
   - [x] Tapping on a post's username or profile photo goes to that user's profile page (+2pt)
- [x] User can comment on a post and see all comments for each post in the post details screen (+3pt)
- [x] User can like a post and see number of likes for each post in the post details screen (+1pt)
- [x] Run your app on your phone and use the camera to take the photo (+1pt)

The following **additional** features are implemented:

- [x] Created moving gradient for login/signup screen
- [x] Created custom viewcontroller for picking images using the Photos framework
- [x] Integrated Facebook SDK for login/registering
- [x] Integrated Microsoft cognitive recognition API to check if picture contains a cat
- [x] Allow user to search nearby locations to tag photo with using MKLocalSearch
- [x] Allow user to switch between tableview and collectionview in profile section
- [x] Used Firebase Firestore for backend

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1.
2.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Walkthough](Cattogram.gif)

## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [RSKPlaceholderTextView](https://github.com/ruslanskorb/RSKPlaceholderTextView) - Textview with placeholder text
- [Firebase](https://firebase.google.com) - Used for backend services
- [Facebook SDK](https://developers.facebook.com/docs/ios/) - Used to integrate Facebook services into application

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright [2017] [Siraj Zaneer]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
