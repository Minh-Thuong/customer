import 'package:customer/datasource/category_datasource.dart';
import 'package:customer/model/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategories();
}

class CategoryRepository extends ICategoryRepository {
  final ICategoryDatasource _datasource;

  CategoryRepository(this._datasource);
  @override
  Future<List<Category>> getCategories() async {
    try {
      final result = await _datasource.getCategories();
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
