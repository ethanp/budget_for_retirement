import 'package:ethan_utils/ethan_utils.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';

class LifeEvents({
  required final List<int> ageAtChildren,
  required final List<Job> jobs,
  required final int ageAtRetirement,
  required final int endAge,
  required final int startingAge,
  var int currentAge = -1,
}) {
  this {
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

  Job get currentJob => jobs
      .sortedOn((job) => job.age.now)
      .lastWhere((job) => job.age.now <= currentAge);

  Iterable<int> get currentChildAges =>
      ageAtChildren.where((c) => c <= currentAge).map((c) => currentAge - c);
}
