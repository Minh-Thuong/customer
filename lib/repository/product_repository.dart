import 'package:customer/datasource/product_datasource.dart';
import 'package:customer/model/product.dart';

abstract class IProductRepository {
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(String id, int page, int limit);
}

class ProductRepository extends IProductRepository {
  final ProductDatasource _datasource;

  ProductRepository(this._datasource);
  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await _datasource.getProducts();
      return response;
    } catch (e) {
       rethrow;
    }
  }
  
  @override
  Future<List<Product>> getProductsByCategory(String id, int page, int limit) async {
    try {
      final result = await _datasource.getProductsByCategory(id, page, limit);
      return result; 
    } catch (e) {
      rethrow;
    }
  }
}
