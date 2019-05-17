// Copyright 2017 mnlin<mnlin0905@gmail.com>.

/// 关卡1:
import 'package:flutter/material.dart';
import 'package:flutter_study/PlusPlugins.dart';

/// 移动的方向:左,上,右,下
enum MoveDirection { LEFT, UP, RIGHT, DOWN }

/// 保留全局的变量参数,控制当前的空格位置
/// 1 表示单元格内存在布局 , 0 表示目前空白的单元格
var _POSITIONS = [
  [1, 1, 1, 1],
  [1, 1, 1, 1],
  [1, 1, 1, 1],
  [1, 1, 1, 1],
  [1, 0, 0, 1]
];

/// 默认的初始位置,包括人物坐标信息及其尺寸颜色
/// 横坐标x轴 | 纵坐标y轴 | 角色名称 | 默认颜色 | 宽度 | 高度
final List<List<dynamic>> _KLOTSKIROLES = [
  [1, 2, "张飞", Colors.redAccent, 0, 0],
  [2, 2, "曹操", Colors.blueAccent, 1, 0],
  [1, 2, "马超", Colors.greenAccent, 3, 0],
  [1, 2, "赵云", Colors.teal, 0, 2],
  [2, 1, "关羽", Colors.yellowAccent, 1, 2],
  [1, 2, "黄忠", Colors.cyan, 3, 2],
  [1, 1, "卒", Colors.pink, 0, 4],
  [1, 1, "卒", Colors.pink, 1, 3],
  [1, 1, "卒", Colors.pink, 2, 3],
  [1, 1, "卒", Colors.pink, 3, 4],
];

///程序入口
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text("关卡1"),
        centerTitle: false,
      ),
      body: BetWeen(),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          return FloatingActionButton(
            child: Text("reset"),
            tooltip: "还原为默认状态",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("重置?"),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          print("点击了确认");
                          Navigator.pop(context, true);
                        },
                        child: Text("确认!"),
                      )
                    ],
                  );
                },
              ).then((value) {
                //如果为true,表示请求还原为默认状态,这时,需要重新创建 widgets
                if (value.runtimeType == bool && value) {}
              }).catchError((err) {
                print(err);
              });
            },
          );
        },
      ),
    ),
  ));
}

/// 中间层
class BetWeen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Stack(
        children: <Widget>[
          Positioned(
            child: KlotskiOne(),
            left: 0,
            top: 0,
            right: 0,
          )
        ],
      ),
      width: double.infinity,
      height: double.infinity,
    );
  }

  ///从数据库中/文件中 获取上次记录
  getContent() async {}
}

///关卡主界面
class KlotskiOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: LayoutBuilder(builder: (context, constraints) {
          //初始化宽高分子度量
          KlotskiRole._widthAtom = constraints.maxWidth / 4;
          KlotskiRole._heightAtom = constraints.maxHeight / 5;

          //返回主布局(通过配置文件生成)
          return Stack(
            textDirection: TextDirection.ltr,
            children: List.from(_KLOTSKIROLES.map((item) {
              return KlotskiRole(
                item[0],
                item[1],
                item[2],
                item[3],
                defaultLeftNum: item[4],
                defaultTopNum: item[5],
              );
            }), growable: false),
          );
        }),
      ),
    );
  }
}

/// 可移动的position布局(用于Stack)
class KlotskiRole extends StatefulWidget {
  /// 宽/最小计量
  static double _widthAtom;

  /// 高/最小计量
  static double _heightAtom;

  /// 控件自身宽
  final int _widthNum;

  /// 控件自身高
  final int _heightNum;

  /// 文本信息
  final String _title;

  /// 背景颜色值
  final Color _bgColor;

  ///左上角坐标:x轴(*最小计量) 初始值
  final int defaultLeftNum;

  ///左上角坐标:y轴 初始值
  final int defaultTopNum;

  @override
  State createState() => _KlotskiRoleState(leftNum: defaultLeftNum, topNum: defaultTopNum);

  KlotskiRole(this._widthNum, this._heightNum, this._title, this._bgColor, {Key key, this.defaultLeftNum = 0, this.defaultTopNum = 0})
      : assert(_heightNum != null),
        assert(_widthNum != null),
        super(key: key);
}

/// state for CanMovePosition
class _KlotskiRoleState extends State<KlotskiRole> {
  ///左上角坐标:x轴(*最小计量)
  int leftNum;

  ///左上角坐标:y轴
  int topNum;

  /// 提供默认的坐标点
  _KlotskiRoleState({this.leftNum = 0, this.topNum = 0});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: leftNum * KlotskiRole._widthAtom,
      top: topNum * KlotskiRole._heightAtom,
      width: widget._widthNum * KlotskiRole._widthAtom,
      height: widget._heightNum * KlotskiRole._heightAtom,
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(border: new Border.all(width: 1.0, color: Colors.white), color: widget._bgColor),
          alignment: Alignment.center,
          child: Text(
            widget._title,
            textAlign: TextAlign.center,
          ),
        ),
        onHorizontalDragEnd: (detail) {
          if (detail.primaryVelocity > 0) {
            //向右滑动
            computeTarget(MoveDirection.RIGHT);
          } else if (detail.primaryVelocity < 0) {
            //向左滑动
            computeTarget(MoveDirection.LEFT);
          }
        },
        onVerticalDragEnd: (detail) {
          if (detail.primaryVelocity > 0) {
            //向下滑动
            computeTarget(MoveDirection.DOWN);
          } else if (detail.primaryVelocity < 0) {
            //向上滑动
            computeTarget(MoveDirection.UP);
          }
        },
      ),
    );
  }

  /// 計算移动后的坐标位置 ,若返回true,则提前修改 [_POSITIONS]
  bool computeTarget(MoveDirection direction) {
    //需要判断的两个点位坐标
    var newPositions = [];
    var oldPositions = [];

    //若可移动,执行回调
    RVoidZeroP callback;

    //判断方式
    var judge = (Function callback) {
      //判断有无越界以及目标位置是否空闲
      bool result = newPositions.every((item) {
        return item[1] <= 4 && item[1] >= 0 && item[0] <= 3 && item[0] >= 0 && _POSITIONS[item[1]][item[0]] == 0;
      });

      //如果成功,则将新位置的值置为 1 / 将原来位置置为0
      if (result) {
        newPositions.every((item) {
          _POSITIONS[item[1]][item[0]] = 1;
          return true;
        });

        oldPositions.every((item) {
          _POSITIONS[item[1]][item[0]] = 0;
          return true;
        });
        
        //触发更新状态
        setState(() {
          callback();
        });
      }

      return result;
    };

    // 滑动方向
    switch (direction) {
      case MoveDirection.LEFT:
        {
          //当左移时,横轴变化
          newPositions.add([leftNum - 1, topNum]);
          oldPositions.add([leftNum + widget._widthNum - 1, topNum]);

          //可能存在需要判断的第二个点
          newPositions.add([leftNum - 1, topNum + widget._heightNum - 1]);
          oldPositions.add([leftNum + widget._widthNum - 1, topNum + widget._heightNum - 1]);

          callback = () {
            leftNum--;
          };
          break;
        }
      case MoveDirection.UP:
        {
          //当上移时,纵轴变化
          newPositions.add([leftNum, topNum - 1]);
          oldPositions.add([leftNum, topNum + widget._heightNum - 1]);

          //可能存在需要判断的第二个点
          newPositions.add([leftNum + widget._widthNum - 1, topNum - 1]);
          oldPositions.add([leftNum + widget._widthNum - 1, topNum + widget._heightNum - 1]);

          callback = () {
            topNum--;
          };
          break;
        }
      case MoveDirection.RIGHT:
        {
          //当右移时,横轴变化
          newPositions.add([leftNum + widget._widthNum, topNum]);
          oldPositions.add([leftNum, topNum]);

          //可能存在需要判断的第二个点
          newPositions.add([leftNum + widget._widthNum, topNum + widget._heightNum - 1]);
          oldPositions.add([leftNum, topNum + widget._heightNum - 1]);

          callback = () {
            leftNum++;
          };
          break;
        }
      case MoveDirection.DOWN:
        {
          //当下移时,纵轴变化
          newPositions.add([leftNum, topNum + widget._heightNum]);
          oldPositions.add([leftNum, topNum]);

          //可能存在需要判断的第二个点
          newPositions.add([leftNum + widget._widthNum - 1, topNum + widget._heightNum]);
          oldPositions.add([leftNum + widget._widthNum - 1, topNum]);

          callback = () {
            topNum++;
          };
          break;
        }
    }

    //返回判断结果
    return judge(callback);
  }
}
