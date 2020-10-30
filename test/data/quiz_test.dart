import 'package:flutter_test/flutter_test.dart';
import 'package:smart_broccoli/src/data.dart';

void main() {
  test('Question equality', () {
    final Question questionTF1 = TFQuestion("a", true);
    final Question questionTF2 = TFQuestion("a", false);
    final Question questionTF3 = TFQuestion("a", true);
    final Question questionMC1 = MCQuestion("a", []);
    final Question questionMC2 = MCQuestion("a", [QuestionOption("a", true)]);
    final Question questionMC3 = MCQuestion("a", [QuestionOption("a", true)]);

    // True/false not equal
    expect(questionTF1 == questionTF2, false);
    // True equal
    expect(questionTF1 == questionTF3, true);

    // TF not MC
    expect(questionTF1 == questionMC1, false);

    // MC no option equal
    expect(questionMC1 == questionMC2, false);
    expect(questionMC2 == questionMC3, true);
  });

  test('Serialise TFQuestion', () {
    final TFQuestion question = TFQuestion("0 < 1?", true);
    final json = question.toJson();
    expect(json, isA<Map<String, dynamic>>());
    expect(json.length, 6);
    expect(json['id'], null);
    expect(json['no'], null);
    expect(json['text'], "0 < 1?");
    expect(json['type'], "truefalse");
    expect(json['tf'], true);
    expect(json['options'], null);
    expect(json['pictureId'], null);
  });

  test('Serialise TFQuestion declared as Question', () {
    final Question question = TFQuestion("0 < 1?", true);
    final json = question.toJson();
    expect(json, isA<Map<String, dynamic>>());
    expect(json.length, 6);
    expect(json['id'], null);
    expect(json['no'], null);
    expect(json['text'], "0 < 1?");
    expect(json['type'], "truefalse");
    expect(json['tf'], true);
    expect(json['options'], null);
    expect(json['pictureId'], null);
  });

  test('Serialise MC option', () {
    final QuestionOption option = QuestionOption("I'm an option", true);
    final json = option.toJson();
    expect(json, isA<Map<String, dynamic>>());
    expect(json.length, 2);
    expect(json['text'], "I'm an option");
    expect(json['correct'], true);
  });

  test('Serialise MCQuestion', () {
    final QuestionOption opt0 = QuestionOption("Opt 0", true);
    final QuestionOption opt1 = QuestionOption("Opt 1", false);
    final QuestionOption opt2 = QuestionOption("Opt 2", false);
    final QuestionOption opt3 = QuestionOption("Opt 3", false);
    final MCQuestion question =
        MCQuestion("I'm an MC question", [opt0, opt1, opt2, opt3]);
    final json = question.toJson();
    expect(json, isA<Map<String, dynamic>>());
    expect(json['id'], null);
    expect(json['no'], null);
    expect(json['text'], "I'm an MC question");
    expect(json['type'], "choice");
    expect(json['tf'], null);
    expect(json['options'], isA<List<Map<String, dynamic>>>());
    expect(json['options'].length, 4);
    expect(json['options'][0], isA<Map<String, dynamic>>());
    expect(json['options'][0].length, 2);
    expect(json['options'][0]['text'], "Opt 0");
    expect(json['options'][0]['correct'], true);
    expect(json['pictureId'], null);
  });

  test('Serialise MCQuestion declared as Question', () {
    final QuestionOption opt0 = QuestionOption("Opt 0", true);
    final QuestionOption opt1 = QuestionOption("Opt 1", false);
    final QuestionOption opt2 = QuestionOption("Opt 2", false);
    final QuestionOption opt3 = QuestionOption("Opt 3", false);
    final Question question =
        MCQuestion("I'm an MC question", [opt0, opt1, opt2, opt3]);
    final json = question.toJson();
    expect(json, isA<Map<String, dynamic>>());
    expect(json['id'], null);
    expect(json['no'], null);
    expect(json['text'], "I'm an MC question");
    expect(json['type'], "choice");
    expect(json['tf'], null);
    expect(json['options'], isA<List<Map<String, dynamic>>>());
    expect(json['options'].length, 4);
    expect(json['options'][0], isA<Map<String, dynamic>>());
    expect(json['options'][0].length, 2);
    expect(json['options'][0]['text'], "Opt 0");
    expect(json['options'][0]['correct'], true);
    expect(json['pictureId'], null);
  });

  test('Serialise list of Questions', () {
    final Question tfq = TFQuestion("0 < 1?", true);
    final QuestionOption opt0 = QuestionOption("Opt 0", true);
    final QuestionOption opt1 = QuestionOption("Opt 1", false);
    final QuestionOption opt2 = QuestionOption("Opt 2", false);
    final QuestionOption opt3 = QuestionOption("Opt 3", false);
    final Question mcq =
        MCQuestion("I'm an MC question", [opt0, opt1, opt2, opt3]);
    final List<Question> questions = [tfq, mcq];

    final jsons = questions.map((q) => q.toJson()).toList();

    expect(jsons.length, 2);

    expect(jsons[0], isA<Map<String, dynamic>>());
    expect(jsons[0].length, 6);
    expect(jsons[0]['id'], null);
    expect(jsons[0]['no'], null);
    expect(jsons[0]['text'], "0 < 1?");
    expect(jsons[0]['type'], "truefalse");
    expect(jsons[0]['tf'], true);
    expect(jsons[0]['options'], null);
    expect(jsons[0]['pictureId'], null);

    expect(jsons[1], isA<Map<String, dynamic>>());
    expect(jsons[1]['id'], null);
    expect(jsons[1]['no'], null);
    expect(jsons[1]['text'], "I'm an MC question");
    expect(jsons[1]['type'], "choice");
    expect(jsons[1]['tf'], null);
    expect(jsons[1]['options'], isA<List<Map<String, dynamic>>>());
    expect(jsons[1]['options'].length, 4);
    expect(jsons[1]['options'][0], isA<Map<String, dynamic>>());
    expect(jsons[1]['options'][0].length, 2);
    expect(jsons[1]['options'][0]['text'], "Opt 0");
    expect(jsons[1]['options'][0]['correct'], true);
    expect(jsons[1]['pictureId'], null);
  });
}
