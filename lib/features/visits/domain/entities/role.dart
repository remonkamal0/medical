enum Role {
  rep,
  senior,
  supervisor,
  manager,
  areaManager,
  marketingDirector,
  scientificDirector,
  ceo;

  String get label => switch (this) {
    rep => 'Product Specialist',
    senior => 'Senior Product Specialist',
    supervisor => 'Product Supervisor',
    manager => 'Product Manager',
    areaManager => 'Area Manager',
    marketingDirector => 'Marketing Director',
    scientificDirector => 'Scientific Director',
    ceo => 'CEO',
  };

  bool get isManager => this != rep;
}
