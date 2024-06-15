class Disruption {
  String? id;
  String? category;
  String? severity;
  bool? suppressed;
  String? message;
  String? description;

  Disruption.fromJson(Map<String, dynamic> json) {
    id = json['t5:id'];
    category = json['t5:category'];
    severity = json['t5:severity'];
    suppressed = (json['t5:isSuppressed'] == "true") ? true : false;
    message = json['t5:xhtmlMessage'];
    description = json['t5:description'];
  }

  Map toJson() {
    return {
      'id': id,
      'category': category,
      'severity': severity,
      'suppressed': suppressed,
      'message': message,
      'description': description,
    };
  }
}