import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/card_model.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CardFlipper(
                cards: cards
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}

class CardFlipper extends StatefulWidget {

  final List<CardModel> cards;

  const CardFlipper({Key key, this.cards}) : super(key: key);

  @override
  _CardFlipperState createState() => _CardFlipperState();
}

class _CardFlipperState extends State<CardFlipper>
    with TickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishingController;

  @override
  void initState() {
    finishingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          scrollPercent = lerpDouble(
            finishScrollStart,
            finishScrollEnd,
            finishingController.value,
          );
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    finishingController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;
    final numCards = widget.cards.length;

    setState(() {
      scrollPercent =
          (startDragPercentScroll + (-singleCardDragPercent / numCards))
              .clamp(0.0, 1.0 - (1 / numCards));
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final numCards = widget.cards.length;

    finishScrollStart = scrollPercent;
    finishScrollEnd = (scrollPercent * numCards).round() / numCards;
    finishingController.forward(from: 0.0);

    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,

      // para poder tocar em qualquer parte do app
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: _buildCards(),
      ),
    );
  }

  List<Widget> _buildCards() {
    final cardCount = widget.cards.length;

    int index = -1;
    return widget.cards.map((CardModel cardModel){
      ++index;
      return _buildCard(cardModel, index, cardCount, scrollPercent);
      
    }).toList();
  }

  Widget _buildCard(CardModel cardModel, int cardIndex, int cardCount, double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    final parallax = scrollPercent - (cardIndex / cardCount);

    return FractionalTranslation(
      translation: Offset(cardIndex - cardScrollPercent, 0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CardLayout(
          cardModel: cardModel,
          parallaxPercent: parallax,
        ),
      ),
    );
  }
}

class CardLayout extends StatelessWidget {

  final CardModel cardModel;
  final double parallaxPercent;

  const CardLayout({Key key, this.cardModel, this.parallaxPercent = 0.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ClipRRect(
          child: FractionalTranslation(
            translation: Offset(parallaxPercent * 2.0, 0.0),
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Image.asset(
                cardModel.photoAssetPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
            Colors.black87,
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Fate/stay night",
                  style: TextStyle(
                      color: Color(0xFFFA5858),
                      fontSize: 44,
//                    fontWeight: FontWeight.w500,
                      fontFamily: "AmaticSC"),
                ),
                Text(
                  "Unlimited Blade Works",
                  style: TextStyle(
                      color: Color(0xFFF78181),
                      fontSize: 22,
                      fontFamily: "AmaticSC",
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "The Holy Grail War is a battle royale among seven magi who serve as Masters. Masters, through the use of the command seals they are given when they enter the war, command Heroic Spirits known as Servants to fight for them in battle. In the Fifth Holy Grail War, Rin Toos...",
                  style: TextStyle(
                    color: Color(0xFFF6CECE),
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
