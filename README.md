# smart-broccoli

Fun quiz app for school lecturers and students to interact with each other in and after class. 
Multiple sensors are used in the app, such as Gyroscope, GPS, Calendar, Wifi and Ambient Light Sensor. 

## Prerequisite
* [Android Studio 4.1](https://developer.android.com/studio)
* Android SDK which can be obtained when launch Android Studio first time. Version: >=2.7.0 && <3.0.0
* [Flutter installation](https://flutter.dev/docs/get-started/install)
* Dart installation : Dart will be automatically installed
* [Android phone or emulator with API level 30](https://developer.android.com/studio/run/managing-avds) with google player services (for firebase)

For detailed installation instructions of Android studio and flutter, please refer to their corresponding official websites. Environment variable configuration should be needed in these processes.

## Dependencies
For details of the dependencies used in this project, please refer to the following pubspec.yaml files. 

```
smart-broccoli/pubspec.yaml
```

Please run ```flutter pub get``` in terminal every time update pubspec.yaml file. 

## Code Structure
* Base ```smart-broccoli/lib/src/base```: 

* Data ```smart-broccoli/lib/src/data```: Contains domain objects and Data Transfer Objects. Including: User, Quiz, Game, Group, Answer and Outcome. Please refer to the file for detailed attributes of each data type defined here.

* Backend ```smart-broccoli/backend```: see [README.md](https://github.com/comp90018-2020/smart-broccoli/blob/master/backend/README.md)


* Frontend ```smart-broccoli/lib/src/ui```: Contains all the UI pages of this repository. These sub packages are rough grouping of the features for code separation. They do not have one-to-one correspondence with the features defined in our Requirement Document.
  * ```/auth```: UI for making account associations
  * ```/group``` and ```/groups```: UI of tap and group management, including UI of group creation and list of group. Also including quiz tap which allows for switching quiz type in take quiz page
  * ```/profile```:  User profile UI and logic 
  * ```/quiz``` and ```quiz_creator```: Quiz card UI, including UI of quiz creation, quiz management, quiz picture and UI of question creation. Also including UI of quiz notification settings page
  * ```/session```: Session UI pages. Contains waiting lobby page, question page, answer page, and leaderboard page
  * ```/shared```: Custom components used by all UI pages
  * ```/about```: Acknowledgement and LICENSE UI

* Sensor ```smart-broccoli/lib/src/background```: Sensors implementation. 
* Services 
  * ```smart-broccoli/lib/src/models```: Used for storing and updating logic state, and be as a middle layer service
  * ```smart-broccoli/lib/src/store```: Contians APIs that used for data transfer between server and UI pages


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
