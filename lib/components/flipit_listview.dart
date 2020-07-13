import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flipit/flipit.dart';

/// Flipit Widget
class FlipitListView extends StatefulWidget{

  /// 스크롤에 대한 제어를 담당하는 Scroll Controller 입니다.
  /// 
  /// 별도로 선언이 되지 않을 경우 자체적으로 생성하여 사용합니다.
  final ScrollController scrollController;

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


  /// 페이지가 변경되었을 경우 실행되는 Callback Function 입니다.
  /// 
  /// 스크롤이 동작되기 시작할 때의 Index 값과 스크롤이 끝났을 때의 Index 값을 비교하여
  /// 값이 달라졌을 경우에만 실행됩니다.
  final Function(int index) onPageChanged;

  const FlipitListView({
    Key key,
    this.scrollController,
    @required this.widgets,
    @required this.itemDimension,
    this.itemWidth,
    this.padding,
    this.onPageChanged,
  }) : super(key: key);

  @override
  _FlipitListViewState createState() => _FlipitListViewState();
}

class _FlipitListViewState extends State<FlipitListView>{
  ScrollController _scrollController;
  List<Widget> get _widgets => this.widget.widgets;
  double get _itemDimension => this.widget.itemDimension;
  double get _itemWidth => this.widget.itemWidth;
  EdgeInsets get _padding => this.widget.padding;
  Function get _onPageChanged => this.widget.onPageChanged;

  double screenW() => MediaQuery.of(context).size.width;
  double screenH() => MediaQuery.of(context).size.height;

  ScrollPhysics _scrollPhysics;

  double _currentOffset = 0;
  double _currentPage = 0;

  int _previousIndex;
  int _nowIndex = 0;


  @override
  void initState() {
    super.initState();
    _scrollPhysics = FlipitScrollPhysics(
      itemDimension: _itemDimension,
    );

    if(this.widget.scrollController != null) _scrollController = this.widget.scrollController;
    else _scrollController = ScrollController();

    _scrollController.addListener((){
      _currentOffset = (_scrollController.offset/_itemDimension);
      _currentPage = _currentOffset;
      if(_currentPage<=0) _currentPage = 0;
      else if((_currentPage-_currentPage.toInt()) >= 0.5) _currentPage = _currentPage.toInt()+1.0;
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
            try{
              if(_previousIndex == null) _previousIndex = (_currentPage.toInt()*_itemDimension).toInt();
            }catch(e){
              print("(TRACE) Scroll Notification or Dimensions got the some problem.");
              throw e;
            }
          } else if (scrollNotification is ScrollUpdateNotification) {
            if(_currentOffset > _widgets.length-1){
              try{
                Future.delayed(Duration.zero,(){
                  _scrollController.jumpTo(
                    ((_widgets.length-1)*_itemDimension)
                  );
                });
              }catch(e){
                print("(TRACE) Scroll Notification or Dimensions got the some problem.");
                throw e;
              }
            }
          } else if (scrollNotification is ScrollEndNotification) {
            if(_currentPage > 0){
              try{
                Future.delayed(Duration.zero,(){
                  _scrollController.animateTo(
                    (_currentPage.toInt()*_itemDimension),
                    duration: kTabScrollDuration,
                    curve: Curves.easeInOut,
                  );
                });
              }catch(e){
                print("(TRACE) Scroll Notification or Dimensions got the some problem.");
                throw e;
              }
            }

            // Page Updated Callback Function
            try{
              if(_previousIndex != null && _onPageChanged != null){
                _nowIndex = _currentPage.toInt();
                if(_previousIndex != _nowIndex) _onPageChanged(_nowIndex);
              }
            }catch(e){
              print("(TRACE) Widget has some problem about count to index.");
              throw e;
            }
            
            _previousIndex = null;
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
        value = (_currentOffset - index).abs();
        if(index >= _currentOffset) value = 1.0;
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
            index >= _currentPage ?
            screenH()-(screenH()*(_currentPage-index)).clamp(0, screenH()) :
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