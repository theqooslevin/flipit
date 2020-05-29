
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flipit/flipit.dart';

/// Flipit Carousel Widget
class FlipitCarousel extends StatefulWidget{

  /// Carousel Controller를 지정합니다.
  ///
  /// Flipit Carousel에서 사용될 Controller를 지정합니다.
  /// Scroll Position 및 페이지 상태 관리를 위해 필요합니다.
  final FlipitCarouselController controller;

  /// Carousel Layout을 지정합니다.
  ///
  /// Flipit Carousel에서 사용될 Layout을 지정합니다.
  /// Pagination 위치에 대한 설정이 변경되며, customize의 경우 Stack 구조로 변경됩니다.
  final FlipitCarouselLayoutType type;

  /// Carousel 지정합니다.
  ///
  /// Flipit Carousel에서 사용될 Layout을 지정합니다.
  /// Pagination 위치에 대한 설정이 변경되며, Stack 구조로 변경됩니다.
  final Function(Widget paginationWidget) positioned;

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
  /// Pagination의 Point의 Padding, Size, Color 값을 설정할 수 있습니다.
  final double pointPadding;
  final double pointSize;
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

  /// 페이지가 변경될 때의 Function을 지정합니다.
  ///
  /// 현재 페이지 값을 double 형식으로 return 합니다.
  final Function(double currentPage) onPageChanged;

  /// 위젯의 Padding 값을 지정합니다.
  final EdgeInsets padding;

  const FlipitCarousel({
    @required Key key,
    @required this.controller,
    @required this.type,
    this.positioned,
    @required this.widgets,
    @required this.margin,
    this.paginationMargin,
    this.pointPadding = 10,
    this.pointSize = 10,
    this.pointSelectedColor = Colors.black,
    this.pointDefaultColor = Colors.grey,
    this.itemMargin,
    this.itemHeight,
    this.itemWidth,
    this.padding,
    this.onPageChanged,
  }) : assert(controller != null, 'You must provide a Flipit Carousel Controller'),
      super(key: key);

  @override
  _FlipitCarouselState createState() => _FlipitCarouselState();
}

class _FlipitCarouselState extends State<FlipitCarousel>{
  FlipitCarouselController get _controller => this.widget.controller;
  FlipitCarouselLayoutType get _type => this.widget.type;
  Function get _positioned => this.widget.positioned;

  List<Widget> get _widgets => this.widget.widgets;
  EdgeInsets get _margin => this.widget.margin;
  EdgeInsets get _paginationMargin => this.widget.paginationMargin;

  double get _pointPadding => this.widget.pointPadding;
  double get _pointSize => this.widget.pointSize;
  Color get _pointSelectedColor => this.widget.pointSelectedColor;
  Color get _pointDefaultColor => this.widget.pointDefaultColor;

  EdgeInsets get _itemMargin => this.widget.itemMargin;
  double get _itemHeight => this.widget.itemHeight;
  double get _itemWidth => this.widget.itemWidth;
  EdgeInsets get _padding => this.widget.padding;

  Function get _onPageChanged => this.widget.onPageChanged;

  double screenW() => MediaQuery.of(context).size.width;
  double screenH() => MediaQuery.of(context).size.height;

  FlipitScrollPhysics _scrollPhysics;
  ScrollController _scrollController;


  @override
  void initState() {
    super.initState();
    _scrollPhysics = FlipitScrollPhysics(
      itemDimension: _itemWidth,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(FlipitCarousel oldWidget) {
    if (oldWidget.controller != widget.controller) {
      widget.controller.addListener((){
        setState(() {});
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void _scrollListener() {
    _controller.currentOffset = (_scrollController.offset/_itemWidth);
    _controller.currentPage = _controller.currentOffset;
    if(_controller.currentPage<=0){
      _controller.currentPage = 0;
    }else if((_controller.currentPage-_controller.currentPage.toInt()) >= 0.5){
      _controller.currentPage = _controller.currentPage.toInt()+1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _margin,
      width: screenW(),
      child: _buildType(),
    );
  }

  Widget _buildType(){
    switch(_type){
      case FlipitCarouselLayoutType.customize:
        return Container(
          width: screenW(),
          height: _itemHeight,
          child: Stack(
            children: <Widget>[
              Container(
                width: screenW(),
                height: _itemHeight,
                child: FlipitScrollbar(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollStartNotification) {
                      } else if (scrollNotification is ScrollUpdateNotification) {
                      } else if (scrollNotification is ScrollEndNotification) {
                      }
                      try{
                        if(_onPageChanged != null) _onPageChanged(this._controller.currentPage);
                        setState(() {});
                      }catch(e){
                        print("(TRACE) Scroll Notification or Dimensions got the some problem.");
                        throw e;
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: _scrollPhysics,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: false,
                      itemCount: _widgets.length,
                      itemBuilder: (context, index){
                        return Container(
                          margin: _itemMargin,
                          padding: _padding,
                          width: _itemWidth,
                          height: _itemHeight,
                          child: _widgets[index],
                        );
                      },
                    ),
                  ),
                ),
              ),
              _positioned != null ? _positioned(
                Container(
                  margin: _paginationMargin,
                  height: _pointSize,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: _paginationPoints(),
                  ),
                )
              ) : Container(child: Text("This widget need a customized positioned widget."),),
            ],
          ),
        );
      default:
        return Column(
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
                      if(_controller.currentOffset > _widgets.length-1){
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
                    }
                    try{
                      if(_onPageChanged != null) _onPageChanged(this._controller.currentPage);
                      setState(() {});
                    }catch(e){
                      print("(TRACE) Scroll Notification or Dimensions got the some problem.");
                      throw e;
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: _scrollPhysics,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: false,
                    itemCount: _widgets.length,
                    itemBuilder: (context, index){
                      return Container(
                        margin: _itemMargin,
                        padding: _padding,
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
              height: _pointSize,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: _paginationPoints(),
              ),
            )
          ],
        );
    }
  }

  List<Widget> _paginationPoints(){
    List<Widget> rows = [];
    for(int idx=0; idx < _widgets.length; idx++){
      rows.add(Container(
        width: _pointSize,
        height: _pointSize,
        decoration: BoxDecoration(
          color: (idx == _controller.currentPage) ? _pointSelectedColor : _pointDefaultColor,
          borderRadius: BorderRadius.all(Radius.circular(_pointSize*2)),
        ),
      ));
      if(idx < _widgets.length) rows.add(SizedBox(width: _pointPadding));
    }

    return rows;
  }
}

class FlipitCarouselController extends ChangeNotifier {
  double currentOffset = 0;
  double currentPage = 0;

  static FlipitCarouselController of(BuildContext context) {
    final chewieControllerProvider = context.dependOnInheritedWidgetOfExactType<_FlipitCarouselControllerProvider>();
    return chewieControllerProvider.controller;
  }

  void setPage(double pageNumber){
    currentOffset = pageNumber;
    currentPage = currentOffset;
    notifyListeners();
  }
}

class _FlipitCarouselControllerProvider extends InheritedWidget {
  const _FlipitCarouselControllerProvider({
    Key key,
    @required this.controller,
    @required Widget child,
  })  : assert(controller != null),
        assert(child != null),
        super(key: key, child: child);
  final FlipitCarouselController controller;

  @override
  bool updateShouldNotify(_FlipitCarouselControllerProvider old) => controller != old.controller;
}

enum FlipitCarouselLayoutType{
  normal,
  customize
}