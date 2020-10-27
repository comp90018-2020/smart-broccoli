import 'package:flutter_test/flutter_test.dart';
import 'package:smart_broccoli/src/data.dart';

main() async {
  test('outcome test', () async {
    var outcomeHost = {
      'question': 6, // the question which was just completed
      'leaderboard': [
        {
          'player': {'id': 18, 'name': "Harald Søndergaard", 'pictureId': 8864},
          'record': {
            'oldPos': 5, // null if this is Q1
            'newPos': 1,
            'bonusPoints': 2000,
            'points': 9999999,
            'streak': 3 // no. consecutive questions correct
          }
        },
        {
          'player': {'id': 20, 'name': "Mia Zhao", 'pictureId': 8888},
          'record': {
            'oldPos': 3, // null if this is Q1
            'newPos': 2,
            'bonusPoints': 1000,
            'points': 8888888,
            'streak': 4 // no. consecutive questions correct
          }
        }
      ],
//     'record': {
//         'oldPos': 9,
//         'newPos': 3,
//         'bonusPoints': 2020,
//         'points': 877777,
//         'streak': 3
//     },
//     'playerAhead': {
//         'player': {
//             'id': 2,
//             'name': "Harry Cheater",
//             'pictureId': 9981
//         },
//         'record':{
//              'oldPos': 6,
//              'newPos': 2,
//              'bonusPoints': 2341,
//              'points': 948270,
//              'streak': 9
//         }
//     }
    };

    var rank = {
      'player': {'id': 18, 'name': "Harald Søndergaard", 'pictureId': 8864},
      'record': {
        'oldPos': 5, // null if this is Q1
        'newPos': 1,
        'bonusPoints': 2000,
        'points': 9999999,
        'streak': 3 // no. consecutive questions correct
      }
    };
    print(outcomeHost['leaderboard']);

    UserRank userrank = UserRank.fromJson(rank);
    print(userrank);

    Outcome host = Outcome.fromJson(outcomeHost);
    print(host);
    print(host.question);
  });
}
