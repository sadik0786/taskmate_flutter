class FinancialYearModel {
  int? id;
  String? yearString;
  String? startDate;
  String? endDate;
  bool? isCurrent;

  FinancialYearModel({
    this.id,
    this.yearString,
    this.startDate,
    this.endDate,
    this.isCurrent,
  });

  FinancialYearModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    yearString = json['YearString'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
    isCurrent = json['IsCurrent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['YearString'] = yearString;
    data['StartDate'] = startDate;
    data['EndDate'] = endDate;
    data['IsCurrent'] = isCurrent;
    return data;
  }
}
