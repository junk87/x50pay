import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:x50pay/common/app_route.dart';
import 'package:x50pay/common/base/base_stateful_state.dart';
import 'package:x50pay/common/base/base_view_model.dart';
import 'package:x50pay/r.g.dart';

mixin BasePage<T extends StatefulWidget> on BaseStatefulState<T> {
  BaseViewModel? baseViewModel();
  Widget body();
  HeaderType headerType = HeaderType.normal;
  bool isShowFooter = false;
  bool isHeaderBackType = false;
  String? floatHeaderText;
  bool isDarkHeader = false;
  void Function()? debugFunction;

  @override
  Widget build(BuildContext context) {
    if (baseViewModel() != null) {
      headerType =
          baseViewModel()!.isFloatHeader ? HeaderType.float : HeaderType.normal;
      isShowFooter = baseViewModel()!.isShowFooter;
      isHeaderBackType = baseViewModel()!.isHeaderBackType;
      floatHeaderText = baseViewModel()!.floatHeaderText;
    }

    return ChangeNotifierProvider.value(
      value: baseViewModel(),
      builder: (context, _) => GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          floatingActionButton: kDebugMode && debugFunction != null
              ? FloatingActionButton(
                  onPressed: debugFunction,
                  child: const Icon(Icons.developer_mode))
              : null,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    children: [
                      headerType == HeaderType.normal
                          ? _Header(isDark: isDarkHeader)
                          : _Header.float(
                              isBackType: isHeaderBackType,
                              title: floatHeaderText,
                              isDark: isDarkHeader),
                      body(),
                      isShowFooter
                          ? const Padding(
                              padding: EdgeInsets.all(30), child: _Footer())
                          : const SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HeaderType _type;
  final bool isDark;
  final bool isBackType;
  final String? title;
  const _Header({Key? key, this.isDark = false})
      : _type = HeaderType.normal,
        isBackType = false,
        title = null,
        super(key: key);

  const _Header.float(
      {Key? key, required this.isBackType, this.title, this.isDark = false})
      : _type = HeaderType.float,
        assert(isBackType != false || title != null,
            'floatHeaderText must be set'),
        super(key: key);
  String get _title => 'X50 Pay - $title';

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case HeaderType.normal:
        return Container(
          color: const Color(0xff1e1e1e),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                    backgroundImage: R.image.header_icon_rsz(),
                    backgroundColor: Colors.black,
                    radius: 14),
              ],
            ),
          ),
        );
      case HeaderType.float:
        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 1,
          color: const Color(0xff1e1e1e),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: isBackType
                  ? [
                      const SizedBox(width: 15),
                      Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xffdfdfdf)),
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(Icons.chevron_left_outlined,
                                size: 25, color: Color(0xff5a5a5a))),
                      ),
                      const SizedBox(width: 10),
                    ]
                  : [
                      const SizedBox(width: 15),
                      CircleAvatar(
                          backgroundImage: R.image.header_icon_rsz(),
                          backgroundColor: const Color(0xff5a5a5a)),
                      const SizedBox(width: 15),
                      Text(_title),
                    ],
            ),
          ),
        );
    }
  }
}

class _Footer extends StatelessWidget {
  const _Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
            text: TextSpan(
                text: 'Copyright © ',
                style: const TextStyle(color: Color(0xff919191)),
                children: [
              TextSpan(
                  text: 'X50 Music Game Station',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      final Uri emailLaunchUri =
                          Uri(scheme: 'mailto', path: 'pay@x50.fun');
                      launchUrl(emailLaunchUri,
                          mode: LaunchMode.externalApplication);
                    })
            ])),
        const SizedBox(height: 10),
        RichText(
            text: TextSpan(
                text: '如使用本平台視為同意',
                style: const TextStyle(color: Color(0xff919191)),
                children: [
              TextSpan(
                  text: '平台使用條款',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.pushNamed(AppRoutes.license.routeName);
                    })
            ]))
      ],
    );
  }
}

enum HeaderType {
  normal,
  float,
}
