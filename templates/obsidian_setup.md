# Obsidian 配置指南

## 插件安装

### 必需插件

1. **Templater**
   - 功能：模板管理
   - 配置：启用插件，设置模板文件夹为 `templates`

2. **QuickAdd**
   - 功能：快速添加内容
   - 配置：创建宏来调用Templater脚本

3. **Git**
   - 功能：版本控制
   - 配置：启用自动拉取/推送

4. **Advanced Tables**
   - 功能：表格编辑
   - 配置：启用插件

5. **Image Toolkit**
   - 功能：图片预览和管理
   - 配置：启用插件

### 可选插件

1. **Dataview** - 数据查询和展示
2. **Calendar** - 日记和日程管理
3. **Excalidraw** - 绘图工具
4. **Outliner** - 大纲优化
5. **Style Settings** - 主题样式调整

## 文件夹结构配置

### 建议的Obsidian库结构

```
My Obsidian Vault/
├── .obsidian/                    # Obsidian配置
├── templates/                    # 模板文件
│   ├── blog_template.md
│   ├── case_template.md
│   ├── techshare_template.md
│   └── obsidian_templater.js    # Templater脚本
├── 网站内容/                     # 网站内容
│   ├── 案例研究/                # 对应 0x00_Cases
│   ├── 博客文章/                # 对应 0x01_Blogs
│   │   └── 2024/                # 按年份组织
│   ├── 方法论/                  # 对应 0x02_Methodology
│   ├── 技术分享/                # 对应 0x03_TechShare
│   │   ├── 技术文章/
│   │   ├── 脚本/
│   │   ├── 工具/
│   │   └── 灵感/
│   ├── 归档/                    # 对应 0x04_archives
│   │   └── images/              # 图片资源
│   └── 关于/                    # 对应 0xff_About
├── 工作区/                      # 日常工作区
│   ├── 待办事项/
│   ├── 会议记录/
│   └── 学习笔记/
└── 资源/                        # 参考资料
    ├── 书籍/
    ├── 文章/
    └── 工具/
```

## Templater 配置

### 1. 启用Templater

在Obsidian设置中：
1. 社区插件 → 浏览 → 搜索 "Templater"
2. 安装并启用
3. 重启Obsidian

### 2. 配置模板文件夹

1. 打开Templater设置
2. 设置模板文件夹位置：`templates`
3. 启用所有脚本功能

### 3. 添加快捷命令

在Templater设置中，添加快捷命令：

```yaml
命令名称: 创建Hugo文章
模板文件: obsidian_templater.js
函数名: createHugoArticle
热键: Ctrl+Shift+H
```

## QuickAdd 配置

### 1. 创建宏

1. 打开QuickAdd设置
2. 点击 "Manage Macros"
3. 添加新宏："Hugo文章创建"

### 2. 配置宏步骤

```yaml
宏名称: Hugo文章创建
步骤:
  1. 类型: Template
     模板: obsidian_templater.js
     函数: createHugoArticle
  2. 类型: Capture
     目标文件: {{MACRO:步骤1:filePath}}
     内容: {{MACRO:步骤1:content}}
```

### 3. 添加快捷方式

在QuickAdd设置中，将宏添加到快速访问菜单。

## Git 集成

### 1. 基础配置

```bash
# 在Obsidian库中初始化Git
cd "My Obsidian Vault"
git init
git add .
git commit -m "Initial commit"

# 连接到远程仓库（如果需要）
git remote add origin git@github.com:yourname/obsidian-vault.git
git push -u origin main
```

### 2. Git插件配置

1. 启用Git插件
2. 设置自动拉取间隔：10分钟
3. 启用自动推送
4. 设置提交信息模板

## 同步工作流

### 方案A：符号链接（推荐）

```bash
# 创建符号链接
ln -s "/path/to/My Obsidian Vault/网站内容" "/path/to/hugo-site/content"

# 验证链接
ls -la /path/to/hugo-site/content
```

### 方案B：使用同步脚本

1. 将 `scripts/sync_obsidian.sh` 复制到合适位置
2. 修改脚本中的路径配置
3. 设置定时任务：

```bash
# 每天自动同步
0 9 * * * /path/to/scripts/sync_obsidian.sh sync

# 每周备份
0 10 * * 1 /path/to/scripts/sync_obsidian.sh backup
```

### 方案C：手动同步

1. 在Obsidian中写作
2. 定期运行同步脚本
3. 检查同步结果
4. 本地预览：`hugo server -D`
5. 发布：提交到GitHub

## 写作规范

### 1. 文件命名
- 使用英文或拼音，避免特殊字符
- 使用连字符分隔单词：`my-first-blog.md`
- 保持简洁明了

### 2. Front Matter规范

```yaml
---
title: "文章标题"                    # 必填
date: 2024-01-01T10:00:00+08:00     # 必填
draft: true                         # 发布前为true
tags: ["标签1", "标签2"]           # 必填
categories: ["分类1"]               # 必填
summary: "文章摘要"                 # 推荐
featuredImage: "/images/xxx.jpg"   # 可选
---
```

### 3. 内容格式

#### 标题层级
```markdown
# 一级标题（文章标题）
## 二级标题（主要章节）
### 三级标题（子章节）
#### 四级标题（细节）
```

#### 代码块
````markdown
```语言
// 代码内容
```
````

#### 图片
```markdown
![图片描述](/0x04_archives/images/图片名.jpg)
```

#### 链接
```markdown
[链接文本](链接地址)
```

#### 表格
```markdown
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 数据1 | 数据2 | 数据3 |
| 数据4 | 数据5 | 数据6 |
```

#### 提示框
```markdown
:::tip
提示内容
:::

:::warning
警告内容
:::

:::note
注意内容
:::
```

## 快捷键配置

### 自定义快捷键

在 `.obsidian/hotkeys.json` 中添加：

```json
{
  "templater:create-hugo-article": {
    "modifiers": ["Ctrl", "Shift"],
    "key": "H"
  },
  "quickadd:hugo-article-macro": {
    "modifiers": ["Ctrl", "Alt"],
    "key": "H"
  },
  "editor:insert-code-block": {
    "modifiers": ["Ctrl", "Shift"],
    "key": "C"
  },
  "editor:insert-image-link": {
    "modifiers": ["Ctrl", "Shift"],
    "key": "I"
  }
}
```

### 常用操作

1. **创建新文章**: `Ctrl+Shift+H`
2. **插入代码块**: `Ctrl+Shift+C`
3. **插入图片**: `Ctrl+Shift+I`
4. **插入表格**: `Ctrl+Shift+T`
5. **保存并同步**: `Ctrl+S` → 运行同步脚本

## 主题和样式

### 推荐主题
1. **AnuPpuccin** - 美观的彩色主题
2. **Minimal** - 简洁高效
3. **Blue Topaz** - 功能丰富

### 自定义CSS

在 `.obsidian/snippets/` 中添加自定义CSS：

```css
/* 增强编辑体验 */
.cm-s-obsidian {
  font-family: 'JetBrains Mono', 'Consolas', monospace;
}

/* 代码块样式 */
.cm-s-obsidian pre.HyperMD-codeblock {
  background-color: #1e1e1e;
  color: #d4d4d4;
}

/* 链接样式 */
.cm-url {
  color: #58a6ff;
}

/* 标题样式 */
.cm-header-1 {
  color: #ff7b72;
}
.cm-header-2 {
  color: #79c0ff;
}
.cm-header-3 {
  color: #56d364;
}
```

## 故障排除

### 常见问题

1. **模板不生效**
   - 检查模板文件夹路径
   - 重启Obsidian
   - 检查Templater插件是否启用

2. **同步失败**
   - 检查文件权限
   - 检查路径是否正确
   - 查看同步日志

3. **Git冲突**
   - 先拉取最新更改
   - 手动解决冲突
   - 重新提交

4. **图片不显示**
   - 检查图片路径
   - 确保图片已复制到正确位置
   - 检查文件权限

### 调试方法

1. 查看Obsidian开发者控制台：`Ctrl+Shift+I`
2. 检查插件日志
3. 测试同步脚本：`./scripts/sync_obsidian.sh dry-run`
4. 检查文件权限：`ls -la`

## 最佳实践

### 1. 定期备份
- 使用Git定期提交
- 使用同步脚本备份
- 考虑云备份方案

### 2. 版本控制
- 每次重大修改前提交
- 使用有意义的提交信息
- 定期清理历史记录

### 3. 内容管理
- 及时清理无用文件
- 定期整理分类
- 保持结构清晰

### 4. 性能优化
- 避免单个文件过大
- 定期清理缓存
- 禁用不需要的插件

## 更新日志

- 2024-01-01: 创建配置指南
- 2024-01-01: 添加模板和脚本
- 2024-01-01: 完善同步工作流

---

**维护者**: Your Name
**最后更新**: {{date}}
**版本**: 1.0.0
```