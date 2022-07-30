library iconfont_builder;

// 通过pub global activate 全局注册
// pub global activate --source path ./
import 'dart:io';
import 'package:args/args.dart';
import 'package:lpinyin/lpinyin.dart';

ArgResults args;


void main(List<String> arguments) {
// 创建ArgParser的实例，同时指定需要输入的参数
  final ArgParser argParser = new ArgParser()
    ..addOption('class', help: "Iconfont class name", defaultsTo: 'Iconfont')
    ..addOption('family', help: "font's family name", defaultsTo: 'Iconfont')
    ..addOption('from', help: "from iconfont dir path")
    ..addOption('to', help: "to .dart file path")
    ..addOption('focus', abbr: 'f', help: "Overlay file")
    ..addOption('package', help: 'font package')
    ..addOption('type',
        abbr: 't', defaultsTo: 'IconData', help: "Use other type")
    ..addFlag('help',
        abbr: 'h', negatable: false, help: "Displays this help information.");

  args = argParser.parse(arguments);

  if (args['help']) {
    print("""
---- HELP ----
${argParser.usage}
""");
  } else {
    logic();
  }
}

String pwd(String from) {
  if (from[0] == '/' || from[0] == '~') {
    return from;
  }
  return '${Directory.current.path}/$from';
}

List<String> keyword = [
  'switch',
  'if',
  'else',
  'void',
  "new",
  "set",
  "get",
  "Icon",
  "icon",
  "where",
  "required",
  "private",
  "public",
  "List",
  'print',
  'toString',
  'int',
  'String',
  'double',
  'bool',
  'var',
  'final',
  'const',
  'static',
  'Set',
  'List',
  'Map',
  'for',
  'return',
  'break',
  'while',
  "library",
  "import",
];

List<String> symbols = [
  '_',
  ' ',
  '-',
  '\\',
  '.',
  '+',
  '=',
  '!',
  '@',
  '#',
  '\$',
  '%',
  '^',
  '&',
  '*',
  '(',
  ')',
  '[',
  ']',
  '{',
  '}',
  ';',
  '\'',
  ',',
  '/',
  '?',
  '<',
  '>'
];

void logic() {
  final fromHtmlPath = pwd('${args['from']}/demo_index.html');
  final toDartPath = pwd(args['to']);

  if (args['focus'] != 'true' && File(toDartPath).existsSync()) {
    print('[Error]');
    print('Have file at: $toDartPath');
    print('If your need overlay file, please add "--focus true" in params');
    print(' ');
    return;
  }
  if (FileSystemEntity.isFileSync(fromHtmlPath) == false) {
    print('[Error]');
    print('No Have file at: $fromHtmlPath');
    print(' ');
    return;
  }

  File fromHtml = File(fromHtmlPath);
  final html = fromHtml.readAsStringSync();

  RegExp nameReg = RegExp(r'<div class="name">.*</div>');
  RegExp valueReg = RegExp(r'<span class="icon iconfont">.*</span>');

  List<String> names = [];
  List<String> tips = [];
  Set<String> nameSet = Set();
  List<String> values = [];
  var valuesMatches = valueReg.allMatches(html);
  var namesMatches = nameReg.allMatches(html);

  for (var n in valuesMatches) {
    String v = n.group(0);
    v = v.replaceFirst('<span class="icon iconfont">&#', '0');
    v = v.replaceFirst(';</span>', '');
    values.add(v);
  }

  int re = 0;
  for (var n in namesMatches) {
    if (names.length == values.length) {
      break;
    }
    String v = n.group(0);

    v = v.replaceFirst('<div class="name">', '');
    v = v.replaceFirst('</div>', '');

    // 储存原始名称，作为注释
    tips.add(v);

    // 不允许以数字或下划线开头
    if ('0123456789'.contains(v[0]) || '_'.contains(v[0])) {
      v = 'a$v';
    }

    // 首字母不允许大写
    v = v.replaceRange(0, 1, v[0].toLowerCase());

    v = v.split('_').expand((element) => element.split(':')).map((e) => capitalize(e)).join();
    v = deCapitalize(v);
    print('camelize v=$v');

    // 不允许使用特殊字符
    symbols.forEach((key) {
      v = v.replaceAll(key, '');
    });

    // 不允许使用关键字
    keyword.forEach((key) {
      if (v == key) {
        v = v + 'NoUseThisWord';
      }
    });

    // 中文转拼音
    v = PinyinHelper.getPinyinE(v);
    v = v.replaceAll(' ', '');
    v = v.replaceAll(':', '');

    // 如果名字重复，就在尾部递增
    if (nameSet.contains(v)) {
      re++;
      v += re.toString();
    }
    names.add(v);
    nameSet.add(v);
  }
  nameSet = null;

  String icons = '';
  String fileString;
  for (var i = 0; i < values.length; i++) {
    if (args['type'] == 'Icon') {
      icons += icon(names[i], values[i], tips[i]);
      fileString = fileIcon(icons);
    } else if (args['type'] == 'IconData') {
      icons += iconData(names[i], values[i], tips[i]);
      fileString = fileIconData( iconDataList(names)  + iconNameList(names)
          + iconClassNameList(tips) + icons);
    }
  }

  File(toDartPath).writeAsStringSync(fileString);
  print('Done! The file: $toDartPath');
}

String iconDataList(List<String> names) {
  return '''
    
    static List<IconData> getIconList() {
      return  [${names.join(',')}];
    } 
    
  ''';
}

String iconNameList(List<String> names) {
  final newNames = names.map((e) => '\'$e\'').toList();
  return '''
    
    static List<String> getIconNameList() {
      return  [${newNames.join(',')}];
    } 
  ''';
}

String iconClassNameList(List<String> tips) {
  final newTips = tips.map((e) => '\'$e\'').toList();
  return '''
    
    static List<String> getIconClassNameList() {
      return  [${newTips.join(',')}];
    } 
  ''';
}


String fileIcon(String icons) {
  return '''
import 'package:flutter/material.dart';

IconData makeIcon(int value) {
  return IconData(
    value,
    fontFamily: '${args['family']}',
    matchTextDirection: true,
  );
}

class ${args['class']} {
  $icons
}
''';
}

String fileIconData(String icons) {
  return '''
import 'package:flutter/material.dart';

class ${args['class']} {
  $icons
}
''';
}

String icon(String name, String value, String tip) {
  return '''
  // iconName: $tip
  static $name({Color color, Key key, double size, TextDirection textDirection}) {
    return Icon(makeIcon($value), color: color, key: key, size: size, textDirection: textDirection);
  }

''';
}

String iconData(String name, String value, String tip) {
  return '''
  // iconName: $tip
  static const $name = IconData(
    $value,
    fontFamily: '${args['family']}',
    fontPackage: '${args['package']}',
    matchTextDirection: true,
  );

''';
}

// 异步输出错误信息到标准错误流
void handleError(String msg) {
  stderr.writeln(msg);
  exitCode = 2; //当程序退出，虚拟机检查exitCode，0 表示Success，1 表示Warnings,2 表示Errors
}

String capitalize(String string) {
    return "${string[0].toUpperCase()}${string.substring(1).toLowerCase()}";
}

String deCapitalize(String string) {
  return "${string[0].toLowerCase()}${string.substring(1)}";
}