# コンビニ整理マスター
## Godot 4 UI/UX 资源引用手册

版本：1.0  
目标平台：iPhone 竖屏，后续兼容 Android  
游戏引擎：Godot 4.x  
开发语言：GDScript  
美术风格：日系可爱卡通风  
基准分辨率：720 × 1280

---

# 1. UI 设计规范

## 1.1 视觉定位

游戏采用日本便利店主题的轻松休闲益智风格。

核心视觉元素：

- 奶油白背景
- 橙黄色主按钮
- 薄荷绿辅助按钮
- 天蓝色次级按钮
- 草莓粉奖励和活动元素
- 圆角、柔和描边、轻微阴影
- 商品图标使用统一的卡通透视和光照方向

推荐颜色：

| 用途 | 颜色 | HEX |
|---|---|---|
| 主背景 | 奶油白 | #FFF5DF |
| 主按钮 | 橙黄色 | #FFB83D |
| 辅助按钮 | 薄荷绿 | #7BD99A |
| 次级按钮 | 天蓝色 | #61B9F5 |
| 活动强调 | 草莓粉 | #FF91AA |
| 主文字 | 深棕色 | #65452F |
| 面板 | 浅奶油色 | #FFF0CC |
| 失败提示 | 柔和红色 | #F07878 |

## 1.2 基础布局

设计画布：720 × 1280。

所有重要 UI 必须适配不同 iPhone 屏幕比例。

原则：

1. 使用 Control 节点进行布局。
2. 使用 Anchor 和 Container 控制位置。
3. 不使用大量固定绝对坐标。
4. 文字通过 Label 动态渲染。
5. 背景图片与交互控件分离。
6. 顶部和底部按钮避开刘海、灵动岛及 Home Indicator。
7. 商品图标保持统一尺寸和视觉占比。

建议在游戏内容区域预留：
- 顶部安全边距：约 90 px
- 底部安全边距：约 100 px

这些是 720 × 1280 设计坐标下的初始设计值，最终应在实际 iPhone 设备上测试。

---

# 2. 资源目录结构

项目资源全部放在 res://assets/ 下。

```text
res://
├── assets/
│   ├── ui/
│   │   ├── backgrounds/
│   │   │   ├── bg_home.png
│   │   │   ├── bg_game.png
│   │   │   ├── bg_shop.png
│   │   │   └── bg_result.png
│   │   │
│   │   ├── buttons/
│   │   │   ├── btn_start.png
│   │   │   ├── btn_start_pressed.png
│   │   │   ├── btn_shop.png
│   │   │   ├── btn_settings.png
│   │   │   ├── btn_retry.png
│   │   │   ├── btn_next.png
│   │   │   ├── btn_close.png
│   │   │   └── btn_back.png
│   │   │
│   │   ├── panels/
│   │   │   ├── panel_default.png
│   │   │   ├── panel_result.png
│   │   │   ├── panel_shop.png
│   │   │   ├── panel_settings.png
│   │   │   └── panel_confirm.png
│   │   │
│   │   ├── icons/
│   │   │   ├── icon_coin.png
│   │   │   ├── icon_star.png
│   │   │   ├── icon_heart.png
│   │   │   ├── icon_hint.png
│   │   │   ├── icon_undo.png
│   │   │   ├── icon_shuffle.png
│   │   │   ├── icon_gift.png
│   │   │   ├── icon_sound.png
│   │   │   └── icon_music.png
│   │   │
│   │   └── effects/
│   │       ├── fx_star.png
│   │       ├── fx_coin.png
│   │       └── fx_sparkle.png
│   │
│   ├── items/
│   │   ├── onigiri/
│   │   │   ├── item_onigiri_salmon.png
│   │   │   ├── item_onigiri_tuna.png
│   │   │   └── item_onigiri_kombu.png
│   │   ├── bento/
│   │   │   ├── item_bento_karaage.png
│   │   │   └── item_bento_curry.png
│   │   ├── drinks/
│   │   │   ├── item_drink_milk.png
│   │   │   ├── item_drink_tea.png
│   │   │   ├── item_drink_water.png
│   │   │   └── item_drink_juice.png
│   │   ├── bread/
│   │   │   ├── item_bread_curry.png
│   │   │   └── item_bread_melon.png
│   │   └── sweets/
│   │       ├── item_pudding.png
│   │       ├── item_cake.png
│   │       └── item_dorayaki.png
│   │
│   └── fonts/
│       ├── font_japanese_regular.ttf
│       └── font_japanese_bold.ttf
│
├── scenes/
│   ├── main/
│   │   └── ui_home.tscn
│   ├── game/
│   │   └── ui_game.tscn
│   ├── result/
│   │   └── ui_result.tscn
│   ├── shop/
│   │   └── ui_shop.tscn
│   └── components/
│       ├── item_card.tscn
│       ├── inventory_slot.tscn
│       └── popup_confirm.tscn
│
├── scripts/
│   ├── ui/
│   │   ├── home_ui.gd
│   │   ├── game_ui.gd
│   │   ├── result_ui.gd
│   │   └── shop_ui.gd
│   ├── game/
│   │   └── item_data.gd
│   └── autoload/
│       └── game_manager.gd
│
└── project.godot
```

---

# 3. 图片资源尺寸规范

所有图片使用 PNG，UI 和商品图标要求透明背景。

| 资源 | 推荐尺寸 | 说明 |
|---|---:|---|
| 游戏 Logo | 600 × 300 | 独立透明 PNG |
| 主背景 | 720 × 1280 | 不透明背景 |
| 游戏背景 | 720 × 1280 | 不透明背景 |
| 普通按钮 | 480 × 128 | 透明 PNG |
| 小图标 | 128 × 128 | 透明 PNG |
| 商品图标 | 256 × 256 | 透明 PNG |
| 弹窗面板 | 640 × 760 | 透明 PNG |
| 金币图标 | 128 × 128 | 透明 PNG |
| 道具图标 | 128 × 128 | 透明 PNG |
| 星星特效 | 256 × 256 | 透明 PNG |

商品图标必须统一：

- 图标主体占画布约 80%。
- 四周保留透明边距。
- 商品尽量居中。
- 不包含商品名称文字。
- 不在商品图片中烘焙阴影以外的 UI 装饰。
- 不同商品保持一致的描边粗细。

## 3.1 按钮状态

建议为需要交互的按钮准备：

```text
btn_start_normal.png
btn_start_pressed.png
btn_start_disabled.png
```

如果使用 TextureButton，分别设置：

- Texture Normal
- Texture Pressed
- Texture Disabled

不需要为每个按钮都制作三套图。对于不需要禁用状态的按钮，可以只准备 Normal 和 Pressed。

## 3.2 透明 PNG 检查

资源处理流程：

1. 从视觉设计稿中单独裁切元素。
2. 清除背景，生成真正的 Alpha 透明通道。
3. 检查边缘是否存在黑边或白边。
4. 将图标调整为规定尺寸。
5. 使用统一命名规则保存。
6. 导入 Godot，检查显示效果。

注意：透明棋盘格只是常见的透明度预览形式，不代表 PNG 一定具有 Alpha 通道。必须使用图像编辑器确认。

推荐工具：
- Krita
- GIMP
- Aseprite（像素素材）
- ImageMagick（批量处理）

---

# 4. Godot 项目显示设置

打开 Project → Project Settings → Display → Window。

推荐配置：

```ini
[display]

window/size/viewport_width=720
window/size/viewport_height=1280
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
```

建议：

- 使用 Portrait 竖屏方向。
- 使用 canvas_items 进行 UI 缩放。
- 通过 Anchor 和 Container 管理布局。
- 不要把所有控件的坐标写死。
- iPhone 真机测试不同屏幕比例和安全区域。

---

# 5. 各页面 UI 布局规范

## 5.1 主界面 ui_home.tscn

节点结构：

```text
HomeUI (Control)
└── Background (TextureRect)
    └── MainLayout (VBoxContainer)
        ├── TopBar (HBoxContainer)
        │   ├── CoinPanel (HBoxContainer)
        │   └── SettingsButton (TextureButton)
        ├── Logo (TextureRect)
        ├── Character (TextureRect)
        ├── StartButton (TextureButton)
        ├── ShopButton (TextureButton)
        └── DailyRewardButton (TextureButton)
```

布局：

- 顶部：金币和设置。
- 中部：Logo 和店员角色。
- 中下部：开始游戏。
- 底部：商店、每日奖励。

主按钮使用橙黄色。

按钮文字由 Label 显示，不写入图片。

## 5.2 游戏界面 ui_game.tscn

节点结构：

```text
GameUI (Control)
├── Background (TextureRect)
├── TopBar (HBoxContainer)
│   ├── LevelLabel (Label)
│   ├── TimerLabel (Label)
│   └── PauseButton (TextureButton)
├── ShelfArea (GridContainer)
├── InventoryPanel (HBoxContainer)
│   ├── Slot1 (TextureRect)
│   ├── Slot2 (TextureRect)
│   ├── Slot3 (TextureRect)
│   ├── Slot4 (TextureRect)
│   ├── Slot5 (TextureRect)
│   ├── Slot6 (TextureRect)
│   └── Slot7 (TextureRect)
├── ItemActions (HBoxContainer)
│   ├── UndoButton (TextureButton)
│   ├── HintButton (TextureButton)
│   └── ShuffleButton (TextureButton)
└── PopupLayer (CanvasLayer)
```

核心规则：

- 玩家点击货架上的商品。
- 商品移动到收纳槽。
- 收纳槽最多 7 格。
- 3 个相同商品自动消除。
- 收纳槽满且没有可消除组合时失败。

货架商品不要烘焙进背景。每个商品都应是单独的 TextureButton 或自定义 Control，以便处理点击和动画。

## 5.3 胜利结算界面 ui_result.tscn

节点：

```text
ResultUI (Control)
├── Background (TextureRect)
├── ResultPanel (NinePatchRect)
│   ├── TitleLabel (Label)
│   ├── StarContainer (HBoxContainer)
│   ├── RewardLabel (Label)
│   ├── NextButton (TextureButton)
│   └── RewardVideoButton (TextureButton)
└── HomeButton (TextureButton)
```

显示内容：

- クリア！
- 关卡星级
- 金币奖励
- 次のステージ
- 广告奖励按钮

失败时可以复用结算场景，动态切换标题和按钮。

## 5.4 商店界面 ui_shop.tscn

布局：

- 顶部金币数量。
- 中部道具商品列表。
- 底部关闭按钮。
- 道具卡片显示图标、名称、数量和价格。

建议第一版只做：

- ヒント：提示。
- もどす：撤销。
- シャッフル：洗牌。
- 追加スロット：增加一个临时槽位。

内购和广告奖励后续再接入。

## 5.5 设置界面

提供：

- BGM 开关。
- SE 音效开关。
- 振动开关。
- 语言设置。
- 隐私政策。
- 使用条款。

---

# 6. Godot UI 图片引用

## 6.1 TextureRect

用于背景、Logo 和非交互图像。

```gdscript
extends Control

@onready var logo: TextureRect = $MainLayout/Logo

func _ready() -> void:
    logo.texture = load(
        "res://assets/ui/logo/logo_main.png"
    )
```

## 6.2 TextureButton

用于开始、商店、提示等交互按钮。

```gdscript
extends Control

@onready var start_button: TextureButton = $MainLayout/StartButton

func _ready() -> void:
    start_button.texture_normal = load(
        "res://assets/ui/buttons/btn_start.png"
    )

    start_button.texture_pressed = load(
        "res://assets/ui/buttons/btn_start_pressed.png"
    )

    start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
    get_tree().change_scene_to_file(
        "res://scenes/game/ui_game.tscn"
    )
```

## 6.3 九宫格弹窗

弹窗建议使用 NinePatchRect。

```gdscript
extends NinePatchRect

func _ready() -> void:
    texture = load(
        "res://assets/ui/panels/panel_default.png"
    )

    patch_margin_left = 40
    patch_margin_top = 40
    patch_margin_right = 40
    patch_margin_bottom = 40
```

这样可以拉伸弹窗而不破坏圆角和边框。

制作面板图片时，边缘区域必须设计成可拉伸结构，避免拉伸到文字和装饰。

## 6.4 商品图标动态加载

```gdscript
extends TextureRect

var item_textures := {
    "onigiri_salmon":
        "res://assets/items/onigiri/item_onigiri_salmon.png",

    "drink_milk":
        "res://assets/items/drinks/item_drink_milk.png",

    "pudding":
        "res://assets/items/sweets/item_pudding.png"
}

func set_item(item_id: String) -> void:
    if not item_textures.has(item_id):
        push_warning("Unknown item: " + item_id)
        return

    texture = load(item_textures[item_id])
```

---

# 7. 商品数据管理

建议使用统一商品 ID，不要在游戏逻辑里直接比较图片路径。

创建：

`res://scripts/game/item_data.gd`

```gdscript
class_name ItemData
extends Resource

@export var item_id: String
@export var display_name: String
@export var texture: Texture2D
@export var category: String
```

商品示例：

| ID | 日文名称 | 分类 |
|---|---|---|
| onigiri_salmon | 鮭おにぎり | onigiri |
| onigiri_tuna | ツナマヨおにぎり | onigiri |
| drink_milk | 牛乳 | drinks |
| drink_tea | 緑茶 | drinks |
| bento_karaage | 唐揚げ弁当 | bento |
| pudding | プリン | sweets |

三个相同商品的判断逻辑：

```gdscript
func count_same_items(items: Array, item_id: String) -> int:
    var count := 0

    for item in items:
        if item != null and item.item_id == item_id:
            count += 1

    return count
```

---

# 8. 七格收纳槽 UI

建议创建独立场景：

`res://scenes/components/inventory_slot.tscn`

节点：

```text
InventorySlot (TextureRect)
└── ItemIcon (TextureRect)
```

脚本：

```gdscript
extends TextureRect

@onready var item_icon: TextureRect = $ItemIcon

func set_item(texture: Texture2D) -> void:
    item_icon.texture = texture
    item_icon.visible = texture != null

func clear_item() -> void:
    item_icon.texture = null
    item_icon.visible = false
```

游戏逻辑中使用固定容量：

```gdscript
const MAX_SLOTS := 7

var inventory: Array = []

func add_item(item: ItemData) -> bool:
    if inventory.size() >= MAX_SLOTS:
        return false

    inventory.append(item)
    return true
```

注意：上面是收纳槽 UI 的基础示例。完整玩法还需要在添加商品后检查三个相同商品、移除匹配项、刷新界面，并在槽位满时判断失败。

---

# 9. UI 全局资源管理

创建：

`res://scripts/autoload/ui_assets.gd`

```gdscript
extends Node

const UI_PATH := "res://assets/ui/"

const BUTTONS := {
    "start": UI_PATH + "buttons/btn_start.png",
    "shop": UI_PATH + "buttons/btn_shop.png",
    "settings": UI_PATH + "buttons/btn_settings.png",
    "retry": UI_PATH + "buttons/btn_retry.png",
    "next": UI_PATH + "buttons/btn_next.png"
}

const ICONS := {
    "coin": UI_PATH + "icons/icon_coin.png",
    "star": UI_PATH + "icons/icon_star.png",
    "hint": UI_PATH + "icons/icon_hint.png",
    "undo": UI_PATH + "icons/icon_undo.png",
    "gift": UI_PATH + "icons/icon_gift.png"
}

func get_button(key: String) -> Texture2D:
    if not BUTTONS.has(key):
        push_warning("Button not found: " + key)
        return null

    return load(BUTTONS[key])

func get_icon(key: String) -> Texture2D:
    if not ICONS.has(key):
        push_warning("Icon not found: " + key)
        return null

    return load(ICONS[key])
```

然后在 Project Settings → Autoload 中注册：

名称：UIAssets  
路径：res://scripts/autoload/ui_assets.gd

使用：

```gdscript
$StartButton.texture_normal = UIAssets.get_button("start")
$CoinIcon.texture = UIAssets.get_icon("coin")
```

对于固定资源，Godot 也可以直接使用预加载：

```gdscript
const ICON_COIN = preload(
    "res://assets/ui/icons/icon_coin.png"
)
```

固定资源建议使用 preload，动态选择的资源使用 load。

---

# 10. UI 动画规范

建议统一动画时间：

| 动画 | 时长 |
|---|---:|
| 按钮点击缩放 | 0.08 秒 |
| 弹窗出现 | 0.20 秒 |
| 弹窗关闭 | 0.15 秒 |
| 商品移动 | 0.20 秒 |
| 三消动画 | 0.30 秒 |
| 金币奖励 | 0.50 秒 |

按钮点击动画：

```gdscript
func play_button_click(button: Control) -> void:
    var tween := create_tween()

    tween.tween_property(
        button,
        "scale",
        Vector2(0.92, 0.92),
        0.08
    )

    tween.tween_property(
        button,
        "scale",
        Vector2.ONE,
        0.10
    )
```

三消时可以使用 Tween 控制透明度和缩放。

---

# 11. 资源命名规则

统一采用：

`类型_名称_状态.png`

例如：

```text
btn_start.png
btn_start_pressed.png
icon_coin.png
icon_hint.png
panel_shop.png
bg_home.png
item_onigiri_salmon.png
item_drink_milk.png
fx_sparkle.png
```

命名规则：

- 全部小写。
- 使用英文。
- 单词之间使用下划线。
- 不使用空格。
- 不使用中文文件名。
- 不随意改变已经被代码引用的文件名。

如果修改资源名称，必须同步修改引用路径。

---

# 12. iPhone 适配与性能

1. 采用竖屏布局。
2. 使用 Container 和 Anchor。
3. 重要按钮的实际点击区域建议不小于 88 × 88 设计像素。
4. 不要让弹窗遮挡关键操作。
5. 对大量重复商品图标使用统一尺寸。
6. 避免为每个小图标使用过大的 PNG。
7. 透明 PNG 优先使用适当的压缩设置。
8. 对游戏背景和静态装饰控制纹理尺寸。
9. 在真机上测试 iPhone 刘海、灵动岛和底部安全区。
10. 使用 iOS 导出模板和 Xcode 完成最终导出与测试。

---

# 13. 资源验收清单

每个 PNG 资源必须满足：

- [ ] 文件名符合规范。
- [ ] 尺寸符合资源规格。
- [ ] 透明背景具有真实 Alpha 通道。
- [ ] 没有黑边、白边或杂色。
- [ ] 没有多余的透明边距。
- [ ] 图标主体居中。
- [ ] 与其他图标风格一致。
- [ ] 在 Godot 中显示正常。
- [ ] 在 iPhone 实机上显示正常。
- [ ] 图片没有未经授权的第三方商标或包装。

---

# 14. 第一版 MVP 资源优先级

第一阶段只需要制作以下资源：

| 优先级 | 资源 | 数量 |
|---|---|---:|
| P0 | 主背景 | 1 |
| P0 | 游戏背景 | 1 |
| P0 | Logo | 1 |
| P0 | 开始、重试、下一关按钮 | 3 |
| P0 | 普通弹窗面板 | 1 |
| P0 | 7 格收纳槽背景 | 1 |
| P0 | 商品图标 | 15 |
| P0 | 金币图标 | 1 |
| P0 | 提示、撤销、洗牌图标 | 3 |
| P1 | 商店、设置界面资源 | 约 10 |
| P1 | 星星和奖励特效 | 约 5 |
| P2 | 角色表情和装饰 | 按需增加 |

第一版先完成 15 种商品、20 个关卡和 4 个核心页面，不建议一开始制作大量复杂动画。

---

# 15. 最终开发建议

开发顺序：

1. 完成主界面资源。
2. 完成游戏背景和商品图标。
3. 完成七格收纳槽。
4. 完成三消逻辑。
5. 完成胜利与失败界面。
6. 完成商店和设置。
7. 添加动画和音效。
8. 接入广告与内购。
9. iPhone 真机测试。
10. 准备日本 App Store 上架。

本手册是 UI 资源和 Godot 引用规范。广告 SDK、内购、隐私披露和 App Store 审核应作为独立开发阶段处理。

**核心原则：美术资源与游戏逻辑分离，所有动态文字由 Godot 渲染，商品通过 ID 管理，UI 通过统一资源管理器引用。**