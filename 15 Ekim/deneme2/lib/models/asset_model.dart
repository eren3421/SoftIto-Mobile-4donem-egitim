class Asset {
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double balance;

  const Asset({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.balance,
  });
}