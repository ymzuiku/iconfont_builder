# 便捷生成 Iconfont 图标字体在用于 Flutter

[iconfont.com](https://www.iconfont.cn/) 有 500w 个图标，而且各个公司的设计师还在源源不断的为其增加新的图标，此库仅为了更便捷的在 Flutter 中使用 Iconfont 字体图标库

## 准备工作

从 [iconfont.com](https://www.iconfont.cn/) 网站选择上下载字体包，解压并拷贝 `demo_index.html` 和 `iconfont.ttf` 到项目中

```
- your-project
    - ios
    - android
    - lib
    - fonts
      # 根据此 html 文件进行解析，所以编译前需要保留
      demo_index.html
      iconfont.ttf
```

编辑 pubspec.yaml, 引用文字资源

```yaml
fonts:
  - family: Iconfont
    fonts:
      - asset: fonts/iconfont.ttf
```

## 安装 iconfont_builder 至 dart 全局

请确保电脑有 dart 环境，如果没有请执行安装 dart：

```sh
$ brew install dart
```

将 iconfont_builder 安装至 dart 全局，作为命令行工具进行使用:

```sh
$ pub global activate iconfont_builder
```

## 在 Flutter 中使用 Iconfont

### 使用 IconData 模式

使用 iconfont_builder 编译 Iconfont.dart 文件

```sh
$ iconfont_builder --from ./fonts --to ./lib/Iconfont.dart
```

可以浏览一下刚刚生成的 `lib/Iconfont.dart`, 里面其实就是图标名的映射:

```dart
class Iconfont {
    // iconName: all
  static const all = IconData(
    0xe697,
    fontFamily: 'Iconfont',
    matchTextDirection: true,
  );

  // iconName: back
  static const back = IconData(
    0xe698,
    fontFamily: 'Iconfont',
    matchTextDirection: true,
  );
  ...
```

将图标名作为属性有一个好处就是使用起来 dart 会有很好的提示, 并且 const 属性会在 AOT 编译时就进行处理，有着更好的性能

有的图标命名很随意，甚至有中文名称，iconfont_builder 已经将不符合 dart 命名规范的名称都做了格式化，并且保留了原有的名称作为注释。

```dart
import './Iconfont.dart';

void main() {
  // iconfont 中的图标名字都会映射置 Iconfont 对象中
  // Iconfont.local 是一个 IconData 对象
  final theIcon = Icon(Iconfont.local);
  // ...
}
```

![](view.png)

### 使用 Icon 组件模式

使用 iconfont 编译 Iconfont.dart, 添加 `--type Icon` 命令

```sh
$ iconfont_builder --type Icon --from ./fonts --to ./lib/Iconfont.dart
```

```dart
import './Iconfont.dart';

void main() {
  // 此时，Iconfont.name 是一个函数，直接返回一个 Icon 组件
  final theIcon = Iconfont.data();
}
```

### 使用更短的类名

编译时，添加 `--class 类名` 命令，替换 `Iconfont` 类名

```sh
$ iconfont_builder --from ./fonts --to ./lib/Iconfont.dart --class Icn
```

然后用新的类名进行引用:

```dart
import './Iconfont.dart';

void main() {
  final theIcon = Icon(Icn.name);
}
```

### 自定义字体名

iconfont_builder 默认使用 `Iconfont` 作为 `font-family`, 而有时候我们可能同时使用多个字体, 此时我们需要自定义字体名。

编译时，添加 `--family 字体名` 命令，替换 `Iconfont` 字体名:

```sh
$ iconfont_builder --from ./fonts --to ./lib/Iconfont.dart --family OtherIcon
```

然后编辑 pubspec.yaml, 引用刚刚设定的字体名

```yaml
fonts:
  - family: OtherIcon
    fonts:
      - asset: fonts/iconfont.ttf
```

## 查看帮助

```dart
$ iconfont_builder --help
```
