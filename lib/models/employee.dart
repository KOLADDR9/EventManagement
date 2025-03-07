class Employee {
  final String name;
  final String? email;
  final String? role;
  final String? department;

  Employee({
    required this.name,
    this.email,
    this.role,
    this.department,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['name'] ?? '',
      email: json['email'],
      role: json['role'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'department': department,
    };
  }

  Employee copyWith({
    String? name,
    String? email,
    String? role,
    String? department,
  }) {
    return Employee(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
    );
  }
}