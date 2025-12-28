import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';

class LifeEvents {
  final List<int> ageAtChildren;
  final int endAge;
  final List<Job> jobs;
  final int ageAtRetirement;
  final int startingAge;

  int currentAge;

  LifeEvents({
    required this.ageAtChildren,
    required this.jobs,
    required this.ageAtRetirement,
    required this.endAge,
    required this.startingAge,
    this.currentAge = -1,
  }) {
    // This allows us to run the Dart compiler, but still initialize the [age]
    // to be based on the [startingAge].
    if (currentAge == -1) currentAge = startingAge;
  }

  bool get justRetired => currentAge == ageAtRetirement;

  bool get isRetired => currentAge > ageAtRetirement;

  bool get reachedEndAge => currentAge == endAge;

  bool get pastEndAge => currentAge > endAge;

  bool get justHadChild => ageAtChildren.contains(currentAge);

  int get yearsSinceStart => currentAge - startingAge;

  Job get currentJob =>
      jobs.sortOn((j) => j.age.now).lastWhere((j) => j.age.now <= currentAge);

  Iterable<int> get currentChildAges =>
      ageAtChildren.where((c) => c <= currentAge).map((c) => currentAge - c);
}
