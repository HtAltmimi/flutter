class ProductModel {
  int? id;
  String? name;
  String? weight;
  String? price;
  int? number;

  ProductModel(
      {required this.id,
      required this.name,
      required this.weight,
      required this.price,
      this.number});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        id: json['id'],
        name: json['name'],
        weight: json['weight'],
        price: json['price']);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "weight": this.weight,
      "price": this.price,
      "number": this.number,
    };
  }
}
