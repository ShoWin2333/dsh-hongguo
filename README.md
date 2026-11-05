# dsh-hongguo（个人 fork）

摸鱼短剧：一个 DSH 插件，在右侧边栏里播一部短剧。

这是 [frostming/dsh-hongguo](https://github.com/frostming/dsh-hongguo) 的个人 fork，代码与上游同源，改动集中在我们自己用起来不顺手的地方，细节见 [FORK-NOTES.md](FORK-NOTES.md)：

- **入口只有一个，且都在右侧栏**：右侧栏「开始」引导页里的 `摸鱼短剧` 卡片（打开右侧栏即可看到），点它打开播放器标签页。左侧栏底部按钮、左侧栏面板列表行、More 菜单行、输入框浮条都已经去掉。
- **不再打扰播放**：去掉输入框上方的等待提示浮条，也不再在任务结束时自动暂停短剧——插件完全不碰 composer，播放只受你自己的操作控制。
- **Windows 封面**：上游用 macOS 的 `sips` 转 HEIC 封面，fork 在非 macOS 上改用 WIC（`cover.ps1`），需要系统装了 HEIF 图像扩展。

数据来自 [openhongguo](https://github.com/beilunyang/openhongguo)（第三方短剧平台的非官方 SDK，匿名设备、无需登录）。请仅用于个人学习与研究，内容版权归权利人所有。上游仓库未声明 LICENSE，本 fork 仅原样保存并注明来源。

## 截图

**剧集列表**：顶部推荐一部没看过的热门剧，下面每页 12 部，`换一批` 翻页；`观看历史` 点开才显示。

![剧集列表](docs/home.png)

**播放器**：画面按视频比例自适应，画面内控制条（进度拖动、下一集、倍速、静音、全屏），选集按 50 集分段。

![播放器](docs/player.png)

## 功能

| 位置 | 内容 |
|---|---|
| 入口 | 右侧栏「开始」引导页里的 `摸鱼短剧` 卡片（引导页只在右侧栏打开且为空时显示） |
| 右侧边栏 | `摸鱼短剧` 标签页：推荐卡片 + 剧集列表（带封面、可搜索）→ 分集 → 播放器 |
| 剧集列表 | 按面板宽度自适应：每行 6 / 4 / 3 / 2 部，每页 12 部，`换一批` 翻到下一页 |
| 播放历史 | 记住每部剧看到第几集、第几秒；`观看历史` 按钮点开后一键续播，可单条移除 |
| 播放器 | 画面内控制条、倍速（1–2×）、全屏、自动连播下一集、续播提示 |

## 结构

- **Host 半（`index.js`）**：加载 openhongguo SDK、维护匿名设备档案，提供同源路由 `/api/hongguo/{feed,series,play,media,stream,config,running}`、`/api/hongguo/cover` 与 `/api/hongguo/vendor`。启动时预先拉取剧集列表。CDN 只提供 HEIC 封面：macOS 用 `sips` 转 JPEG，其它平台用 `cover.ps1`（WIC / HEIF 图像扩展）转换并缓存。
- **Client 半（`client.js`）**：只注册右侧栏的两样东西：标签页类型 `hongguo`（带 `guide` 入口卡）和 `sidebar.right.pane.tab` 里的播放器本体。不注册左侧栏入口或主区域页面，不注册任何 composer/dock 插槽，也不监听 Agent 会话状态。

## 播放与解密

视频是 CENC（cenc-aes-ctr）加密的 HEVC，浏览器无法直接解码。Host 用 SDK 解析出的内容密钥调用本机 `ffmpeg` 解密并重封装为普通 MP4（`-c copy`，不重编码），缓存在插件数据目录 `media/`（保留最近 40 集）。页面只拿到同源 `/api/hongguo/media` 地址，密钥不出 Host。

需要安装 ffmpeg：

```powershell
winget install Gyan.FFmpeg      # Windows
brew install ffmpeg             # macOS
```

macOS 下封面走系统 `sips`，无需额外组件；Windows 下 HEIC 封面需要系统已安装 HEIF 图像扩展（Microsoft Store 的「HEIF 图像扩展」，多数系统自带）。

## 构建与安装

本 fork 没有发布到 npm，按本地包安装：

```powershell
cd dsh-hongguo-fork
./build.ps1     # npm install（bundle openhongguo）→ npm pack → 复制到 %USERPROFILE%\.dsh\profiles\desktop\
```

然后在 DSH 的插件管理器里安装 `file:./dsh-hongguo-<version>.tgz`，它会热加载插件。

## 配置

`cordis.patch.yml` 中 `hongguo` 行的 `config`：

| 字段 | 默认 | 说明 |
|---|---|---|
| `autoPrompt` | `true` | 仅为兼容保留，本 fork 不再显示等待提示，无可见效果 |
| `panelWidth` | `480` | 播放器标签页的默认宽度（px） |
| `profilePath` | 插件数据目录 | 匿名设备档案文件；删除即更换设备 |
| `searchTerms` | `总裁/重生/逆袭` | 推荐不足时补充列表用的搜索词 |
