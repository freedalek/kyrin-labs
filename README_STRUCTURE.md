# Kyrin Labs 网站结构说明文档

## 项目概述

这是一个基于Hugo框架的个人网站，使用Loveit主题，部署在GitHub Pages上，配置了自定义域名。网站主要用于展示安全研究、案例分享、技术博客等内容。

## 目录结构说明

### 根目录结构

```
.
├── README.md                    # 项目主说明文档
├── README_STRUCTURE.md          # 本文件 - 详细结构说明
├── hugo.toml                    # Hugo配置文件
├── content/                     # 网站内容目录
│   ├── _index.md               # 首页内容
│   ├── 0x00_Cases/             # 案例研究
│   ├── 0x01_Blogs/             # 博客文章（网页显示为Blogs）
│   ├── 0x02_Methodology/       # 方法论
│   ├── 0x03_TechShare/         # 技术分享（脚本、工具、灵感）
│   ├── 0x04_archives/          # 归档文件（图片等资源）
│   └── 0xff_About/             # 关于页面
├── assets/css/                  # 自定义CSS样式
│   └── _custom.scss            # 主样式文件
├── layouts/                     # 自定义布局
│   ├── home.html               # 首页模板
│   ├── partials/               # 局部模板
│   │   └── head/custom.html    # 自定义头部
│   └── shortcodes/             # 短代码
├── static/                      # 静态资源
│   ├── images/                 # 图片资源
│   │   └── background.jpg      # 背景图片
│   └── CNAME                   # 自定义域名配置
└── themes/                      # 主题目录（通过git submodule管理）
```

### 各模块详细说明

#### 1. 0x00_Cases - 案例研究
**功能**：展示安全研究中的实际案例
**位置**：`content/0x00_Cases/`
**注意事项**：
- 每个案例一个子目录
- 使用 `_index.md` 作为目录索引
- 建议包含：背景、分析过程、技术细节、总结

#### 2. 0x01_Blogs - 博客文章
**功能**：记录技术博客、学习笔记、研究心得
**位置**：`content/0x01_Blogs/`
**网页显示**：Blogs
**注意事项**：
- 支持分类和标签
- 建议使用front matter规范元数据
- 可以按年份/主题组织子目录

#### 3. 0x02_Methodology - 方法论
**功能**：分享研究方法、工作流程、最佳实践
**位置**：`content/0x02_Methodology/`
**注意事项**：
- 在菜单中位置靠后（权重4）
- 适合分享系统性的方法论

#### 4. 0x03_TechShare - 技术分享
**功能**：分享脚本、工具、代码片段、灵感
**位置**：`content/0x03_TechShare/`
**子目录结构**：
```
0x03_TechShare/
├── _index.md                   # 目录索引
├── 0x01_Writeups/             # 技术文章
├── 0x02_Scripts/              # 脚本文件
├── 0x03_Tools/                # 工具介绍
└── 0x04_Inspirations/         # 灵感记录
```

#### 5. 0x04_archives - 归档文件
**功能**：存储图片等资源文件
**位置**：`content/0x04_archives/`
**注意事项**：
- 主要用于存放需要被文章引用的图片
- 建议按年份/项目组织子目录

#### 6. 0xff_About - 关于页面
**功能**：个人介绍、联系方式、网站说明
**位置**：`content/0xff_About/`

## Obsidian集成工作流

### 1. 文件组织建议
```
Obsidian Vault/
├── 网站内容/                  # 对应content目录
│   ├── 案例研究/             # 0x00_Cases
│   ├── 博客文章/             # 0x01_Blogs
│   ├── 方法论/               # 0x02_Methodology
│   ├── 技术分享/             # 0x03_TechShare
│   │   ├── 技术文章/         # Writeups
│   │   ├── 脚本/            # Scripts
│   │   ├── 工具/            # Tools
│   │   └── 灵感/            # Inspirations
│   ├── 归档/                # 0x04_archives
│   └── 关于/                # 0xff_About
└── 网站配置/                  # Hugo配置相关
```

### 2. 自动同步方案

#### 方案A：符号链接（推荐）
```bash
# 在Obsidian vault中创建符号链接
ln -s /path/to/obsidian/网站内容 /path/to/hugo/content
```

#### 方案B：同步脚本
创建同步脚本 `sync_content.sh`：
```bash
#!/bin/bash
# 同步Obsidian内容到Hugo
rsync -av --delete /path/to/obsidian/网站内容/ /path/to/hugo/content/

# 运行Hugo生成静态文件
cd /path/to/hugo
hugo

# 推送到GitHub
git add .
git commit -m "Update: $(date)"
git push origin main
```

#### 方案C：Git子模块
将Obsidian vault作为Git子模块：
```bash
git submodule add git@github.com:yourname/obsidian-vault.git content
```

## 模板系统

### 1. 创建模板目录
```bash
mkdir -p templates
```

### 2. 各模块模板

#### 博客文章模板 (`templates/blog_template.md`)
```markdown
---
title: "{{title}}"
date: {{date}}
draft: true
tags: ["tag1", "tag2"]
categories: ["category1"]
series: ["series1"]
summary: "文章摘要"
---

# {{title}}

## 概述

## 主要内容

### 小节标题

## 总结

## 参考资料

---

> 创建时间: {{date}}
> 最后更新: {{date}}
```

#### 案例研究模板 (`templates/case_template.md`)
```markdown
---
title: "{{title}}"
date: {{date}}
draft: true
tags: ["安全研究", "案例"]
categories: ["案例研究"]
summary: "案例摘要"
difficulty: "中级"  # 初级/中级/高级
time_required: "2小时"  # 预计阅读时间
---

# {{title}}

## 案例背景

## 技术分析

### 发现过程

### 技术细节

## 解决方案

## 经验总结

## 相关资源

---

**关键词**: 
**相关案例**: 
**技术栈**: 
```

#### 技术分享模板 (`templates/techshare_template.md`)
```markdown
---
title: "{{title}}"
date: {{date}}
draft: true
tags: ["工具", "脚本", "技术"]
categories: ["技术分享"]
type: "tool"  # tool/script/inspiration
github_url: "https://github.com/..."  # 可选
license: "MIT"  # 可选
---

# {{title}}

## 简介

## 功能特性

## 使用方法

### 安装

### 配置

### 示例

```bash
# 示例代码
```

## 实现原理

## 注意事项

---

**版本**: 1.0.0
**作者**: Your Name
**更新日志**:
- v1.0.0: 初始版本
```

## 自动化脚本

### 1. 创建新文章的脚本 (`scripts/new_post.sh`)
```bash
#!/bin/bash

# 参数检查
if [ $# -lt 2 ]; then
    echo "用法: $0 <类型> <标题>"
    echo "类型: blog, case, techshare"
    exit 1
fi

TYPE=$1
TITLE=$2
DATE=$(date +"%Y-%m-%d")
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

case $TYPE in
    "blog")
        DIR="content/0x01_Blogs/$(date +%Y)/$SLUG"
        TEMPLATE="templates/blog_template.md"
        ;;
    "case")
        DIR="content/0x00_Cases/$SLUG"
        TEMPLATE="templates/case_template.md"
        ;;
    "techshare")
        DIR="content/0x03_TechShare/$SLUG"
        TEMPLATE="templates/techshare_template.md"
        ;;
    *)
        echo "错误: 未知类型 $TYPE"
        exit 1
        ;;
esac

# 创建目录
mkdir -p "$DIR"

# 使用模板创建文件
if [ -f "$TEMPLATE" ]; then
    sed -e "s/{{title}}/$TITLE/g" -e "s/{{date}}/$DATE/g" "$TEMPLATE" > "$DIR/_index.md"
    echo "创建成功: $DIR/_index.md"
else
    echo "错误: 模板文件 $TEMPLATE 不存在"
    exit 1
fi
```

### 2. Obsidian插件配置

在Obsidian中安装以下插件：
1. **Templater** - 模板管理
2. **QuickAdd** - 快速添加内容
3. **Git** - 版本控制

#### Templater配置示例：
```javascript
// 模板脚本：创建Hugo文章
module.exports = async (params) => {
    const {app, moment} = params;
    
    // 获取标题
    const title = await app.prompt("请输入文章标题：");
    if (!title) return;
    
    // 选择类型
    const type = await app.prompt("请选择文章类型：\n1. 博客\n2. 案例\n3. 技术分享", {
        buttons: ["博客", "案例", "技术分享"]
    });
    
    const date = moment().format("YYYY-MM-DD");
    const slug = title.toLowerCase().replace(/[^a-z0-9]/g, '-');
    
    let path, template;
    switch(type) {
        case "博客":
            path = `网站内容/博客文章/${moment().format('YYYY')}/${slug}.md`;
            template = await app.vault.adapter.read("templates/blog_template.md");
            break;
        case "案例":
            path = `网站内容/案例研究/${slug}.md`;
            template = await app.vault.adapter.read("templates/case_template.md");
            break;
        case "技术分享":
            path = `网站内容/技术分享/${slug}.md`;
            template = await app.vault.adapter.read("templates/techshare_template.md");
            break;
    }
    
    // 替换模板变量
    let content = template
        .replace(/{{title}}/g, title)
        .replace(/{{date}}/g, date)
        .replace(/{{slug}}/g, slug);
    
    // 创建文件
    await app.vault.create(path, content);
    
    return `文章已创建: ${path}`;
};
```

## 最佳实践

### 1. 写作规范
- 使用清晰的标题结构（H1, H2, H3）
- 代码块标注语言类型
- 图片使用相对路径
- 重要内容使用callout（警告、提示等）

### 2. Front Matter规范
```yaml
---
title: "文章标题"
date: 2024-01-01T10:00:00+08:00
draft: false  # 发布前设为true，发布后改为false
tags: ["标签1", "标签2"]
categories: ["分类1"]
series: ["系列名称"]  # 可选
summary: "文章摘要"
featuredImage: "/images/featured.jpg"  # 特色图片
---
```

### 3. 图片管理
- 图片存放在 `content/0x04_archives/images/`
- 按年份和项目组织：`2024/project-name/image.jpg`
- 在文章中使用：`![描述](/0x04_archives/2024/project/image.jpg)`

### 4. 发布流程
1. 在Obsidian中写作并保存
2. 运行同步脚本将内容复制到Hugo
3. 本地测试：`hugo server -D`
4. 生成静态文件：`hugo`
5. 提交到GitHub：`git add . && git commit -m "更新" && git push`

## 故障排除

### 常见问题
1. **图片不显示**：检查图片路径是否正确，确保在 `0x04_archives` 目录下
2. **样式异常**：运行 `hugo server` 查看控制台错误
3. **菜单不更新**：检查 `hugo.toml` 中的菜单配置
4. **GitHub Pages不更新**：检查GitHub Actions日志

### 调试命令
```bash
# 清理缓存
hugo --gc

# 强制重新生成
hugo --force

# 显示详细日志
hugo --verbose

# 只生成特定部分
hugo --renderToMemory
```

## 更新日志

- 2024-01-01: 创建文档
- 2024-01-01: 优化菜单结构，将Research改为Blogs
- 2024-01-01: 添加模板系统和自动化脚本

---

**维护者**: Your Name
**最后更新**: {{date}}
**版本**: 1.0.0
```