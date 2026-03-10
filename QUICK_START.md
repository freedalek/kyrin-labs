# Kyrin Labs 网站快速开始指南

## 已完成的工作

### 1. 网站结构优化 ✅
- 菜单结构调整：Research → Blogs
- Methodology 位置后移（权重4）
- TechShare 作为主要分享模块

### 2. 模板系统 ✅
- 创建了3种文章模板：
  - `templates/blog_template.md` - 博客文章
  - `templates/case_template.md` - 案例研究
  - `templates/techshare_template.md` - 技术分享
- 模板包含完整的Front Matter和内容结构

### 3. 自动化脚本 ✅
- `scripts/new_post.sh` - 创建新文章
- `scripts/sync_obsidian.sh` - 同步Obsidian内容
- 已添加执行权限

### 4. Obsidian集成 ✅
- `templates/obsidian_templater.js` - Templater脚本
- `templates/obsidian_setup.md` - Obsidian配置指南

### 5. 详细文档 ✅
- `README_STRUCTURE.md` - 完整结构说明
- 本快速开始指南

## 快速开始

### 1. 创建新文章

```bash
# 创建博客文章
./scripts/new_post.sh blog "我的第一篇博客" -t "技术,学习" -c "技术博客"

# 创建案例研究
./scripts/new_post.sh case "某系统漏洞分析" -t "安全,漏洞" --author "YourName"

# 创建技术分享
./scripts/new_post.sh techshare "自动化脚本工具" -t "工具,自动化" --type "tool"
```

### 2. 同步Obsidian内容

```bash
# 首次使用前备份
./scripts/sync_obsidian.sh backup

# 同步内容
./scripts/sync_obsidian.sh sync

# 试运行（不实际修改）
./scripts/sync_obsidian.sh dry-run

# 查看状态
./scripts/sync_obsidian.sh status
```

### 3. 本地预览

```bash
# 启动本地服务器
hugo server -D

# 在浏览器中访问
# http://localhost:1313
```

### 4. 发布网站

```bash
# 生成静态文件
hugo

# 提交到GitHub
git add .
git commit -m "更新: $(date)"
git push origin main
```

## Obsidian配置步骤

### 1. 安装必需插件
1. Templater
2. QuickAdd
3. Git
4. Advanced Tables

### 2. 配置文件夹结构
```
My Obsidian Vault/
├── templates/                    # 复制提供的模板
├── 网站内容/                     # 网站内容目录
└── .obsidian/                   # Obsidian配置
```

### 3. 设置Templater
1. 模板文件夹：`templates`
2. 启用脚本功能
3. 添加快捷命令：Ctrl+Shift+H

### 4. 配置同步
```bash
# 创建符号链接（推荐）
ln -s "/path/to/My Obsidian Vault/网站内容" "content"

# 或使用同步脚本
./scripts/sync_obsidian.sh sync
```

## 各模块说明

### Blogs (0x01_Blogs)
- **功能**：技术博客、学习笔记、研究心得
- **位置**：菜单第2位
- **模板**：`blog_template.md`
- **建议**：按年份组织，使用分类和标签

### TechShare (0x03_TechShare)
- **功能**：脚本、工具、代码片段、灵感
- **位置**：菜单第3位
- **模板**：`techshare_template.md`
- **子目录建议**：Writeups, Scripts, Tools, Inspirations

### Case Studies (0x00_Cases)
- **功能**：安全案例分析、研究案例
- **位置**：菜单第1位
- **模板**：`case_template.md`
- **特色**：难度等级、预计时间

### Methodology (0x02_Methodology)
- **功能**：研究方法、工作流程
- **位置**：菜单第4位（靠后）
- **建议**：系统性的方法论分享

## 写作工作流

### 方案A：完全自动化
1. 在Obsidian中使用模板创建文章
2. 自动同步到Hugo
3. 本地预览
4. 发布

### 方案B：半自动化
1. 使用脚本创建文章：`./scripts/new_post.sh`
2. 编辑Markdown文件
3. 手动同步（如果需要）
4. 预览和发布

### 方案C：手动管理
1. 直接在Hugo content目录中创建文件
2. 使用提供的模板
3. 运行Hugo生成网站

## 常用命令

```bash
# 文章管理
./scripts/new_post.sh <类型> <标题> [选项]

# 内容同步
./scripts/sync_obsidian.sh <命令>

# 网站开发
hugo server -D              # 本地开发
hugo                        # 生成静态文件
hugo --gc                   # 清理缓存

# Git操作
git add .
git commit -m "更新"
git push origin main
```

## 故障排除

### 1. 脚本无法执行
```bash
# 添加执行权限
chmod +x scripts/*.sh

# 检查路径
which bash
```

### 2. 同步失败
```bash
# 检查路径配置
vim scripts/sync_obsidian.sh

# 查看日志
cat logs/sync.log
```

### 3. 模板不生效
```bash
# 检查模板文件
ls templates/

# 检查脚本权限
chmod +x scripts/new_post.sh
```

### 4. Hugo错误
```bash
# 清理缓存
hugo --gc

# 显示详细错误
hugo --verbose

# 检查配置
cat hugo.toml
```

## 下一步建议

### 1. 添加实际内容
- 在各个模块的 `_index.md` 中添加介绍
- 创建示例文章
- 完善关于页面

### 2. 自定义样式
- 修改 `assets/css/_custom.scss`
- 添加背景图片到 `static/images/`
- 调整颜色变量

### 3. 配置自动化
- 设置GitHub Actions自动部署
- 配置Obsidian自动同步
- 设置定期备份

### 4. 优化体验
- 添加搜索功能
- 配置评论系统
- 添加分析工具

## 获取帮助

### 文档位置
- `README_STRUCTURE.md` - 完整结构文档
- `templates/obsidian_setup.md` - Obsidian配置
- 本快速开始指南

### 测试命令
```bash
# 测试脚本
./scripts/new_post.sh blog "测试文章" --dry-run

# 测试同步
./scripts/sync_obsidian.sh dry-run

# 测试Hugo
hugo server -D &
curl http://localhost:1313
```

---

**开始使用时间**: {{date}}
**版本**: 1.0.0
**维护者**: Your Name

> 提示：首次使用前，建议先运行测试命令确保一切正常。
```