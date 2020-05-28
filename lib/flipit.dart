library flipit;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flipit/components/flipit_physics.dart';
import 'package:flipit/components/flipit_scrollbar.dart';

/// Flipit Widget
class FlipitListView extends StatefulWidget{

  /// 아이템들을 가져옵니다.
  ///
  /// ListView에서 표시할 아이템들을 가져옵니다.
  final List<Widget> widgets;

  /// 아이템 높이를 지정합니다.
  ///
  /// 일반적인 ListView와 동작 방식이 다르기 때문에, 포함될 아이템의 Height 값을 미리 지정합니다.
  /// 모든 아이템의 Height 값은 모두 동일해야 하며, 다를 경우 올바르게 표시되지 않을 수 있습니다.
  /// 참고로 본 위젯에서 별도의 viewport는 적용되지 않습니다.
  final double itemDimension;

  /// 아이템 너비값을 지정합니다.
  ///
  /// 일반적인 ListView와 동작 방식이 다르기 때문에, 포함될 아이템의 Width 값을 미리 지정합니다.
  /// 모든 아이템의 Width 값은 모두 동일해야 하며, 다를 경우 올바르게 표시되지 않을 수 있습니다.
  /// 참고로 본 위젯에서 별도의 viewport는 적용되지 않습니다.
  final double itemWidth;

  /// 위젯의 Padding 값을 지정합니다.
  final EdgeInsets padding;

  const FlipitListView({
    Key key,
    this.widgets,
    this.itemDimension,
    this.itemWidth,
    this.padding,
  }) : super(key: key);

  @override
  _FlipitListViewState createState() => _FlipitListViewState();
}

class _FlipitListViewState extends State<FlipitListView>{
  List<Widget> get _widgets => this.widget.widgets;
  double get _itemDimension => this.widget.itemDimension;
  double get _itemWidth => this.widget.itemWidth;
  EdgeInsets get _padding => this.widget.padding;

  double screenW() => MediaQuery.of(context).size.width;
  double screenH() => MediaQuery.of(context).size.height;

  ScrollPhysics _scrollPhysics;
  ScrollController _scrollController;

  double currentOffset = 0;
  double currentPage = 0;


  @override
  void initState() {
    super.initState();
    _scrollPhysics = FlipitScrollPhysics(
      itemDimension: _itemDimension,
    );
    _scrollController = ScrollController();

    _scrollController.addListener((){
      currentOffset = (_scrollController.offset/_itemDimension);
      currentPage = currentOffset;
      if(currentPage<=0) currentPage = 0;
      else if((currentPage-currentPage.toInt()) >= 0.5) currentPage = currentPage.toInt()+1.0;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlipitScrollbar(
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollStartNotification) {
          } else if (scrollNotification is ScrollUpdateNotification) {
            if(currentOffset > _widgets.length-1){
              try{
                Future.delayed(Duration.zero,(){
                  _scrollController.animateTo(
                    ((_widgets.length-1)*_itemDimension),
                    duration: Duration.zero,
                    curve: Curves.easeInOut,
                  );
                });
              }catch(e){
                print("(TRACE) Scroll Notification or Dimensions got the some problem.");
                throw e;
              }
            }
          } else if (scrollNotification is ScrollEndNotification) {
            if(currentPage > 0){
              try{
                Future.delayed(Duration.zero,(){
                  _scrollController.animateTo(
                    (currentPage.toInt()*_itemDimension),
                    duration: kTabScrollDuration,
                    curve: Curves.easeInOut,
                  );
                });
              }catch(e){
                print("(TRACE) Scroll Notification or Dimensions got the some problem.");
                throw e;
              }
            }
          }
          return false;
        },
        child: ListView.builder(
          key: this.widget.key,
          padding: _padding,
          physics: _scrollPhysics,
          controller: _scrollController,
          shrinkWrap: false,
          itemBuilder: (context, index){
            return _builder(index);
          },
          itemCount: _widgets.length,
        ),
      ),
    );
  }

  _builder(int index) {
    double cardWidth = _itemWidth;
    double cardHeight = _itemDimension;
    double value = 1.0;
    double offsetY = (cardHeight * (1-value));

    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        value = (currentOffset - index).abs();
        if(index >= currentOffset) value = 1.0;
        else value = 1.0 - value;

        value = index < _widgets.length-1 ? value.clamp(0.0, 1.0).abs() : 1.0;
        offsetY = (cardHeight * (1-value));

        return Opacity(
          opacity: (value*2).clamp(0.0, 1.0).abs(),
          child: Transform.translate(
            transformHitTests: true,
            offset: Offset(0, offsetY),
            child: Transform.scale(
              scale: (value*2).clamp(0.0, 1.0).abs(),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        height: index >= _widgets.length-1 ?
          (
            index >= currentPage ?
            screenH()-(screenH()*(currentPage-index)).clamp(0, screenH()) :
            screenH()
          ) :
          cardHeight,
        color: Colors.transparent,
        child: OverflowBox(
          minWidth: cardWidth,
          minHeight: 0,
          maxWidth: cardWidth,
          maxHeight: index >= _widgets.length-1 ? cardHeight : cardHeight/value,
          alignment: Alignment.topCenter,
          child: _widgets[index],
        ),
      ),
    );
  }
}