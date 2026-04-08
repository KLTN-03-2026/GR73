class Membership {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final int quotaAdd;

  const Membership({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.quotaAdd,
  });

  static List<Membership> plans() => const [
        Membership(id: 'basic', name: 'Basic', price: 299_000, durationDays: 30, quotaAdd: 20),
        Membership(id: 'pro', name: 'Premium', price: 799_000, durationDays: 30, quotaAdd: 999),
        Membership(id: 'vip', name: 'Business', price: 1_090_000, durationDays: 30, quotaAdd: 999),
      ];
}
