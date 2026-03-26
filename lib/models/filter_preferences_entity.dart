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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'season': season,
      'district': district,
      'taluka': taluka,
      'village': village,
      'dateRangeStartMillis': dateRangeStartMillis,
      'dateRangeEndMillis': dateRangeEndMillis,
      'statusesCsv': statusesCsv,
    };
  }

  factory FilterPreferencesEntity.fromJson(Map<String, dynamic> json) {
    return FilterPreferencesEntity(
      id: json['id'] as int? ?? 1,
      year: json['year'] as String?,
      season: json['season'] as String?,
      district: json['district'] as String?,
      taluka: json['taluka'] as String?,
      village: json['village'] as String?,
      dateRangeStartMillis: json['dateRangeStartMillis'] as int?,
      dateRangeEndMillis: json['dateRangeEndMillis'] as int?,
      statusesCsv: json['statusesCsv'] as String? ?? '',
    );
  }
}
