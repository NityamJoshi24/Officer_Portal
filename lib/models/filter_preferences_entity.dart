import 'package:objectbox/objectbox.dart';

@Entity()
class FilterPreferencesEntity {
  FilterPreferencesEntity({
    this.id = 1,
    this.year,
    this.season,
    this.district,
    this.taluka,
    this.village,
    this.dateRangeStartMillis,
    this.dateRangeEndMillis,
    this.statusesCsv = '',
  });

  int id;
  String? year;
  String? season;
  String? district;
  String? taluka;
  String? village;
  int? dateRangeStartMillis;
  int? dateRangeEndMillis;
  String statusesCsv;
}
