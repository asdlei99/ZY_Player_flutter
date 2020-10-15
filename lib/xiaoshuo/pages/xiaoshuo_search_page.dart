import 'dart:convert';

import 'package:ZY_Player_flutter/model/xiaoshuo_resource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/pages/xiaoshuo_detail_page.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:ZY_Player_flutter/xiaoshuo/xiaoshuo_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class XiaoShuoSearchPage extends StatefulWidget {
  @override
  _XiaoShuoSearchPageState createState() => _XiaoShuoSearchPageState();
}

class _XiaoShuoSearchPageState extends State<XiaoShuoSearchPage> {
  final FocusNode _focus = FocusNode();

  XiaoShuoProvider _xiaoShuoProvider = XiaoShuoProvider();

  @override
  void initState() {
    super.initState();
    context.read<PlayerProvider>().setWords();
    _xiaoShuoProvider.setWords();
  }

  Future getData(String keywords) async {
    _xiaoShuoProvider.list.clear();
    _xiaoShuoProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchXiaoshuo, queryParameters: {"keywords": keywords},
        onSuccess: (resultList) {
      _xiaoShuoProvider.setStateType(StateType.empty);
      List.generate(resultList.length, (i) => _xiaoShuoProvider.list.add(XiaoshuoResource.fromJson(resultList[i])));
    }, onError: (_, __) {
      _xiaoShuoProvider.setStateType(StateType.network);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);

    return ChangeNotifierProvider<XiaoShuoProvider>(
        create: (_) => _xiaoShuoProvider,
        child: Scaffold(
          appBar: SearchBar(
              focus: _focus,
              hintText: '请输入小说名称查询',
              onPressed: (text) {
                Toast.show('搜索内容：$text');
                if (text != null) {
                  _xiaoShuoProvider.addWors(text);
                  this.getData(text);
                }
              }),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Consumer<XiaoShuoProvider>(builder: (_, provider, __) {
                  return provider.words.length > 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text("历史搜索"),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: isDark ? Colours.dark_red : Colours.dark_bg_gray,
                                    ),
                                    onPressed: () {
                                      Log.d("删除搜索");
                                      _xiaoShuoProvider.clearWords();
                                    })
                              ],
                            ),
                            Selector<XiaoShuoProvider, List>(
                                builder: (_, words, __) {
                                  return Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Wrap(
                                        spacing: 10,
                                        runSpacing: 5,
                                        children: words.map<Widget>((s) {
                                          return InkWell(
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: isDark ? Colours.dark_material_bg : Colours.bg_gray,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text('$s'),
                                            ),
                                            onTap: () {
                                              //搜索关键词
                                              Toast.show('搜索内容：$s');
                                              this.getData(s);
                                            },
                                          );
                                        }).toList()),
                                  );
                                },
                                selector: (_, store) => store.words)
                          ],
                        )
                      : Container();
                }),
                Expanded(child: Consumer<XiaoShuoProvider>(builder: (_, provider, __) {
                  return provider.list.length > 0
                      ? ListView.builder(
                          itemCount: provider.list.length,
                          itemBuilder: (_, index) {
                            return ListTile(
                              title: Text(provider.list[index].title),
                              subtitle: Text(provider.list[index].author),
                              leading: LoadImage(
                                provider.list[index].cover,
                                fit: BoxFit.cover,
                              ),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                Log.d('前往详情页');
                                String jsonString = jsonEncode(provider.list[index]);
                                NavigatorUtils.push(context,
                                    '${XiaoshuoRouter.detailPage}?xiaoshuoResource=${Uri.encodeComponent(jsonString)})}');
                              },
                            );
                          })
                      : Center(
                          child: StateLayout(type: provider.stateType),
                        );
                }))
              ],
            ),
          ),
        ));
  }
}
