import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:losser_bar/Pages/Model/mate_model.dart';

abstract class MateCatalogService {
  Future<List<MateCatalog>> getAllMateCatalog();
}

class MateCatalogFirebaseService implements MateCatalogService {
  @override
  Future<List<MateCatalog>> getAllMateCatalog() async {
    print("getAllMateCatalog is called");
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('mate_catalog').get();
    print("MateCatalog count: ${qs.docs.length}");
    AllMateCatalog MateCatalogs = AllMateCatalog.fromSnapshot(qs);
    print(MateCatalogs.MateCatalogs);
    return MateCatalogs.MateCatalogs;
  }
}
