
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flipit/components/flipit_physics.dart';
import 'package:flipit/components/flipit_scrollbar.dart';

import 'flipit_physics.dart';
import 'flipit_scrollbar.dart';
import 'flipit_scrollbar.dart';

/// Flipit Carousel Widget
class FlipitCarousel extends StatefulWidget{

  /// 아이템들을 가져옵니다.
  ///
  /// ListView에서 표시할 아이템들을 가져옵니다.
  final List<Widget> widgets;


  /// Wrapper의 Margin을 지정합니다.
  ///
  /// 전체를 감싸는 Wrapper의 Margin 값을 지정합니다.
  final EdgeInsets margin;

  /// Pagination의 Margin을 지정합니다.
  ///
  /// Carousel과 Pagination 사이의 Margin을 지정합니다.
  final EdgeInsets paginationMargin;

  /// Pagination의 Point와 관련된 값을 지정합니다.
  ///
  /// Pagination의 Point의 Padding, Width, Height, Color 값을 설정할 수 있습니다.
  final double pointPadding;
  final double pointWidth;
  final double pointHeight;
  final Color pointSelectedColor;
  final Color pointDefaultColor;

  /// 아이템의 Margin을 지정합니다.
  ///
  /// 아이템의 Margin 값을 지정합니다.
  final EdgeInsets itemMargin;

  /// 아이템 높이를 지정합니다.
  ///
  /// 일반적인 ListView와 동작 방식이 다르기 때문에, 포함될 아이템의 Height 값을 미리 지정합니다.
  /// 모든 아이템의 Height 값은 모두 동일해야 하며, 다를 경우 올바르게 표시되지 않을 수 있습니다.
  /// 참고로 본 위젯에서 별도의 viewport는 적용되지 않습니다.
  final double itemHeight;

  /// 아이템 너비값을 지정합니다.
  ///
  /// 일반적인 ListView와 동작 방식이 다르기 때문에, 포함될 아이템의 Width 값을 미리 지정합니다.
  /// 모든 아이템의 Width 값은 모두 동일해야 하며, 다를 경우 올바르게 표시되지 않을 수 있습니다.
  /// 참고로 본 위젯에서 별도의 viewport는 적용되지 않습니다.
  final double itemWidth;

  /// 위젯의 Padding 값을 지정합니다.
  final EdgeInsets padding;

  const FlipitCarousel({
    Key key,
    this.widgets,
    this.margin,
    this.paginationMargin,
    this.pointPadding,
    this.pointWidth,
    this.pointHeight,
    this.pointSelectedColor,
    this.pointDefaultColor,
    this.itemMargin,
    this.itemHeight,
    this.itemWidth,
    this.padding,
  }) : super(key: key);

  @override
  _FlipitCarouselState createState() => _FlipitCarouselState();
}

class _FlipitCarouselState extends State<FlipitCarousel>{
  List<Widget> get _widgets => this.widget.widgets;
  EdgeInsets get _margin => this.widget.margin;
  EdgeInsets get _paginationMargin => this.widget.paginationMargin;

  double get _pointPadding => this.widget.pointPadding;
  double get _pointWidth => this.widget.pointWidth;
  double get _pointHeight => this.widget.pointHeight;
  Color get _pointSelectedColor => this.widget.pointSelectedColor;
  Color get _pointDefaultColor => this.widget.pointDefaultColor;

  EdgeInsets get _itemMargin => this.widget.itemMargin;
  double get _itemHeight => this.widget.itemHeight;
  double get _itemWidth => this.widget.itemWidth;
  EdgeInsets get _padding => this.widget.padding;

  double screenW() => MediaQuery.of(context).size.width;
  double screenH() => MediaQuery.of(context).size.height;

  FlipitScrollPhysics _scrollPhysics;
  ScrollController _scrollController;

  double currentOffset = 0;
  double currentPage = 0;


  @override
  void initState() {
    super.initState();
    _scrollPhysics = FlipitScrollPhysics(
      itemDimension: _itemWidth,
    );
    _scrollController = ScrollController();

    _scrollController.addListener((){
      currentOffset = (_scrollController.offset/_itemWidth);
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
    return Container(
      margin: _margin,
      width: screenW(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: screenW(),
            height: _itemHeight,
            child: FlipitScrollbar(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                  } else if (scrollNotification is ScrollUpdateNotification) {
                    if(currentOffset > 3-1){
                      try{
                        Future.delayed(Duration.zero,(){
                          _scrollController.animateTo(
                            ((_widgets.length-1)*_itemWidth),
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
                            (currentPage.toInt()*_itemWidth),
                            duration: kTabScrollDuration,
                            curve: Curves.easeInOut,
                          );
                        });
                        setState(() {});
                      }catch(e){
                        print("(TRACE) Scroll Notification or Dimensions got the some problem.");
                        throw e;
                      }
                    }
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: _scrollPhysics,
                  scrollDirection: Axis.horizontal,
                  itemCount: _widgets.length,
                  itemBuilder: (context, index){
                    return Container(
                      margin: _itemMargin,
                      width: _itemWidth,
                      height: _itemHeight,
                      child: _widgets[index],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            margin: _paginationMargin,
            width: screenW(),
            height: _pointHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: _paginationPoints(),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _paginationPoints(){
    List<Widget> rows = [];
    for(int idx=0; idx < _widgets.length; idx++){
      rows.add(Container(
        width: _pointWidth,
        height: _pointHeight,
        decoration: BoxDecoration(
          color: (idx == currentPage) ? _pointSelectedColor : _pointDefaultColor,
          borderRadius: BorderRadius.all(Radius.circular(_pointWidth*2)),
        ),
      ));
      if(idx < _widgets.length) rows.add(SizedBox(width: _pointPadding));
    }

    return rows;
  }
}

