# smart-broccoli

Fun quiz app for school lecturers and students to interact with each other in and after class. Multiple sensors are used in the app, such as Gyroscope, GPS, Calendar, Wifi and Ambient Light Sensor. 

Please note that this repository was made for educational purposes, as part of assessment for the subject [Mobile Computing System Programming (COMP90018)](https://handbook.unimelb.edu.au/2020/subjects/comp90018). It is not intended for use in production environments.

## Prerequisite
* [Android Studio 4.1](https://developer.android.com/studio)
* Android SDK which can be obtained when launch Android Studio first time. Version: >=2.7.0 && <3.0.0
* [Flutter installation](https://flutter.dev/docs/get-started/install)
* Dart installation : Dart will be automatically installed when flutter installation finished
* [Android phone or emulator with API level 30](https://developer.android.com/studio/run/managing-avds)

For detailed installation instructions of Android studio and flutter, please refer to their corresponding official websites. Environment variable configuration should be needed in these processes.

## Dependencies
For details of the dependencies used in this project, please refer to the following pubspec.yaml files. All Dependencies have detailed examples and installation instruction on [pub dev](https://pub.dev).

```
smart-broccoli/pubspec.yaml
```

Please run ```flutter pub get``` in terminal every time update pubspec.yaml file. 

## Code Structure
### Base ```smart-broccoli/lib/src/base```
1. ```/firebase```: 
2. ```/helper```: 
3. ```/pubsub```: 

### Data ```smart-broccoli/lib/src/data```
Contains domain objects and Data Transfer Objects. Including: User, Quiz, Game, Group, Answer and Outcome. Please refer to the file for detailed attributes of each data type defined here.

### Backend ```smart-broccoli/backend```
1. ```/.vscode```: 
2. ```/controllers```: 
3. ```/demo```: 
4. ```/game```: 
5. ```/helpers```: 
6. ```/models```:
7. ```/routers```: 
8. ```/tests```: 

### Frontend ```smart-broccoli/lib/src/ui```
Note: these sub packages are rough grouping of the features for code separation. They do not have one-to-one correspondence with the features defined in our Requirement Document.

1. ```/auth```: UI for making account associations
2. ```/group``` and '''/groups''': UI of tap and group management, including UI of group creation and list of group. Also including quiz tap which allows for switching quiz type in take quiz page
3. ```/profile```:  User profile UI and logic 
4. ```/quiz``` and 'quiz_creator': Quiz card UI, including UI of quiz creation, quiz management, quiz picture and UI of question creation. Also including UI of quiz notification settings page
5. ```/session```: Session UI pages. Contains waiting lobby page, question page, answer page, and leaderboard page
6. ```/shared```: Custom components used by all UI pages
7. ```/about```: Acknowledgement and LICENSE UI

### Sensor ```smart-broccoli/lib/src/background```
1. ```/background_calendar```: 
2. ```/background_database```: 
3. ```/background```: 
4. ```/gyro```: 
5. ```/light_sensor```: 
6. ```/location```:
7. ```/network```: 

### Services 
* ```smart-broccoli/lib/src/models```
1. ```/auth_state```: 
2. ```/group_registry```: 
3. ```/model_change```: 
4. ```/quiz_collection```: 
5. ```/session_model```: 
6. ```/session_tracker```:
7. ```/user_profile```: 
8. ```/user_repository```: 

* ```smart-broccoli/lib/src/store```
1. ```/local```: 
2. ```/remote```: 

## Building and Running
### With Android Studio
1. Clone this repository locally.
2. Open Android Studio, select menu item File -> Open and open the root of your local repository.
3. Before build and run, make sure the Android emulator is available. Select menu item Tool -> AVD manager. Click <create virtual device> button if there is no Android virtual machine, then follow the guideline to complete the installation, this process may take a little bit of time. After that, select and launch one emulator in the list of Android Virtual Devices Manager window. 
4. To build and run the app, select menu item Run -> Run and then in the popup dialog, select smart broccoli app

### With command line

```
flutter run
```
