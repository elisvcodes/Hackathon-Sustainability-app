import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../providers/products.dart';
import '../providers/product.dart';

import 'package:intl/intl.dart';
import '../providers/auth.dart';

math.Random random = new math.Random();
final double _initCarbonUsage = 100, _initLifeTimeValue = 2;

class ProductDetailScreen extends StatefulWidget {
  // final String title;
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double _lifeTimeValue = _initLifeTimeValue;
  double _carbonUsage = _initCarbonUsage;
  double _estimatedPerYear = 1;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<double> _generateRandomData(int count) {
    List<double> result = <double>[];
    for (int i = 0; i < count; i++) {
      result.add(random.nextDouble() * 100);
    }
    return result;
  }

  List<double> _generateCarbonData(int count) {
    List<double> result = <double>[];
    for (int i = 0; i < count; i++) {
      result.add(_carbonUsage * (i / _lifeTimeValue).round());
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // @override
    // void initState() {

    // }

    _estimatedPerYear = 12 / _lifeTimeValue;
    // final product = Provider.of<Product>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    var data = _generateCarbonData(10);
    final flSpotData =
        List.generate(101, (i) => _carbonUsage * (i / _lifeTimeValue).round())
            .map((x) => FlSpot(x / 3, (x)))
            .toList();
    final productId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);

    setState(() {
      _carbonUsage = loadedProduct.carbon;
      _lifeTimeValue = loadedProduct.lifespam;
    });
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              Text(
                '${loadedProduct.title}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '\$${loadedProduct.price}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FlatButton(
                child: Text('Add Product to Tracking'),
                onPressed: () {
                  loadedProduct.toggleFavoriteStatus(
                      authData.token, authData.userId);
                  final snackBar = SnackBar(
                    content: Text(
                      'Item is being Tracked!',
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        loadedProduct.toggleFavoriteStatus(
                            authData.token, authData.userId);
                      },
                    ),
                  );

                  _scaffoldKey.currentState.showSnackBar(snackBar);
                },
                textColor: Theme.of(context).primaryColor,
              ),
              Text("Carbon cost per unit: ${_carbonUsage.toStringAsFixed(3)}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
              Slider(
                value: _carbonUsage,
                min: 0.001 > _carbonUsage ? _carbonUsage * 0.1 : 0.01,
                max: _initCarbonUsage * 10 < _carbonUsage
                    ? _carbonUsage * 2
                    : _initCarbonUsage * 10,
                label: _carbonUsage.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _carbonUsage = value;
                  });
                },
              ),
              Text("Lifespam: ${_lifeTimeValue.toStringAsFixed(3)} (months)",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
              Slider(
                value: _lifeTimeValue,
                min: 1 > _lifeTimeValue ? 0.1 * _lifeTimeValue : 1,
                max: 48 <= _lifeTimeValue ? _lifeTimeValue * 2 : 48,
                divisions: 48 * 2,
                label: _lifeTimeValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _lifeTimeValue = value;
                  });
                },
              ),
              Text(
                  "Estimated purchase per year: ${_estimatedPerYear.toStringAsFixed(3)} times",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
              Container(
                width: 300.0,
                height: 100.0,
                child: new Sparkline(
                  data: data,
                  lineColor: Colors.lightGreen[500],
                  fillMode: FillMode.below,
                  fillColor: Colors.lightGreen[200],
                  pointsMode: PointsMode.all,
                  pointSize: 5.0,
                  pointColor: Colors.amber,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
