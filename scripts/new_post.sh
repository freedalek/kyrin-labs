#!/bin/bash

# ============================================
# Hugo文章创建脚本
# 支持: blog, case, techshare 三种类型
# ============================================

set -e  # 遇到错误退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "用法: $0 <类型> <标题> [选项]"
    echo ""
    echo "类型:"
    echo "  blog       创建博客文章"
    echo "  case       创建案例研究"
    echo "  techshare  创建技术分享"
    echo ""
    echo "选项:"
    echo "  -a, --author <作者>     指定作者 (默认: $(whoami))"
    echo "  -t, --tags <标签>       指定标签，逗号分隔"
    echo "  -c, --category <分类>   指定分类"
    echo "  -s, --series <系列>     指定系列"
    echo "  -d, --date <日期>       指定日期 (默认: 今天)"
    echo "  -o, --output <目录>     输出目录 (默认: content)"
    echo "  -h, --help             显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 blog '我的第一篇博客' -t '技术,学习' -c '技术博客'"
    echo "  $0 case '某系统漏洞分析' -t '安全,漏洞' -d '2024-01-01'"
    echo "  $0 techshare '自动化脚本工具' -t '工具,自动化' --author 'YourName'"
}

# 参数解析
TYPE=""
TITLE=""
AUTHOR=$(whoami)
TAGS=""
CATEGORY=""
SERIES=""
DATE=$(date +"%Y-%m-%d")
OUTPUT_DIR="content"
TEMPLATES_DIR="templates"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--author)
            AUTHOR="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        -c|--category)
            CATEGORY="$2"
            shift 2
            ;;
        -s|--series)
            SERIES="$2"
            shift 2
            ;;
        -d|--date)
            DATE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$TYPE" ]]; then
                TYPE="$1"
            elif [[ -z "$TITLE" ]]; then
                TITLE="$1"
            else
                print_error "多余的参数: $1"
                show_help
                exit 1
            fi
            shift
            ;;
    esac

done

# 参数验证
if [[ -z "$TYPE" ]] || [[ -z "$TITLE" ]]; then
    print_error "缺少必要参数"
    show_help
    exit 1
fi

# 检查模板目录
if [[ ! -d "$TEMPLATES_DIR" ]]; then
    print_error "模板目录不存在: $TEMPLATES_DIR"
    exit 1
fi

# 生成slug（URL友好的标题）
SLUG=$(echo "$TITLE" | \
    tr '[:upper:]' '[:lower:]' | \
    tr ' ' '-' | \
    sed 's/[^a-z0-9-]//g' | \
    sed 's/--*/-/g' | \
    sed 's/^-//;s/-$//')

print_info "创建文章: $TITLE"
print_info "类型: $TYPE"
print_info "Slug: $SLUG"
print_info "日期: $DATE"

# 根据类型设置目录和模板
case $TYPE in
    "blog")
        YEAR=$(date -d "$DATE" +"%Y" 2>/dev/null || date +"%Y")
        CONTENT_DIR="$OUTPUT_DIR/0x01_Blogs/$YEAR/$SLUG"
        TEMPLATE_FILE="$TEMPLATES_DIR/blog_template.md"
        DEFAULT_TAGS="技术,学习"
        DEFAULT_CATEGORY="技术博客"
        ;;
    "case")
        CONTENT_DIR="$OUTPUT_DIR/0x00_Cases/$SLUG"
        TEMPLATE_FILE="$TEMPLATES_DIR/case_template.md"
        DEFAULT_TAGS="安全研究,案例分析"
        DEFAULT_CATEGORY="案例研究"
        ;;
    "techshare")
        CONTENT_DIR="$OUTPUT_DIR/0x03_TechShare/$SLUG"
        TEMPLATE_FILE="$TEMPLATES_DIR/techshare_template.md"
        DEFAULT_TAGS="工具,脚本,技术分享"
        DEFAULT_CATEGORY="技术分享"
        ;;
    *)
        print_error "不支持的类型: $TYPE"
        echo "可用类型: blog, case, techshare"
        exit 1
        ;;
esac

# 使用默认值如果用户未指定
if [[ -z "$TAGS" ]]; then
    TAGS="$DEFAULT_TAGS"
fi

if [[ -z "$CATEGORY" ]]; then
    CATEGORY="$DEFAULT_CATEGORY"
fi

# 检查模板文件
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    print_error "模板文件不存在: $TEMPLATE_FILE"
    exit 1
fi

# 创建目录
print_info "创建目录: $CONTENT_DIR"
mkdir -p "$CONTENT_DIR"

# 准备模板变量
SUMMARY="这是关于 $TITLE 的文章摘要。"
UPDATE_DATE="$DATE"
KEYWORDS="$(echo $TAGS | sed 's/,/, /g')"

# 根据类型设置特定变量
case $TYPE in
    "blog")
        FEATURED_IMAGE="blog-$SLUG.jpg"
        LANGUAGE="javascript"
        ;;
    "case")
        FEATURED_IMAGE="case-$SLUG.jpg"
        DIFFICULTY="中级"
        TIME_REQUIRED="30分钟"
        CASE_TYPE="安全分析"
        TECHNOLOGIES="相关技术栈"
        LANGUAGE="python"
        ;;
    "techshare")
        FEATURED_IMAGE="techshare-$SLUG.jpg"
        TYPE_VALUE="tool"
        VERSION="1.0.0"
        LICENSE="MIT"
        GITHUB_URL="https://github.com/yourusername/$SLUG"
        LANGUAGE="bash"
        ;;
esac

# 读取模板内容
TEMPLATE_CONTENT=$(cat "$TEMPLATE_FILE")

# 替换模板变量
CONTENT="$TEMPLATE_CONTENT"
CONTENT="${CONTENT//{{title}}/$TITLE}"
CONTENT="${CONTENT//{{date}}/$DATE}"
CONTENT="${CONTENT//{{update_date}}/$UPDATE_DATE}"
CONTENT="${CONTENT//{{slug}}/$SLUG}"
CONTENT="${CONTENT//{{author}}/$AUTHOR}"
CONTENT="${CONTENT//{{summary}}/$SUMMARY}"
CONTENT="${CONTENT//{{keywords}}/$KEYWORDS}"
CONTENT="${CONTENT//{{tags}}/$TAGS}"
CONTENT="${CONTENT//{{categories}}/$CATEGORY}"
CONTENT="${CONTENT//{{series}}/$SERIES}"

# 替换类型特定变量
case $TYPE in
    "blog")
        CONTENT="${CONTENT//{{featured_image}}/$FEATURED_IMAGE}"
        CONTENT="${CONTENT//{{language}}/$LANGUAGE}"
        ;;
    "case")
        CONTENT="${CONTENT//{{featured_image}}/$FEATURED_IMAGE}"
        CONTENT="${CONTENT//{{difficulty}}/$DIFFICULTY}"
        CONTENT="${CONTENT//{{time}}/$TIME_REQUIRED}"
        CONTENT="${CONTENT//{{case_type}}/$CASE_TYPE}"
        CONTENT="${CONTENT//{{technologies}}/$TECHNOLOGIES}"
        CONTENT="${CONTENT//{{language}}/$LANGUAGE}"
        ;;
    "techshare")
        CONTENT="${CONTENT//{{featured_image}}/$FEATURED_IMAGE}"
        CONTENT="${CONTENT//{{type}}/$TYPE_VALUE}"
        CONTENT="${CONTENT//{{version}}/$VERSION}"
        CONTENT="${CONTENT//{{license}}/$LICENSE}"
        CONTENT="${CONTENT//{{github_url}}/$GITHUB_URL}"
        CONTENT="${CONTENT//{{language}}/$LANGUAGE}"
        ;;
esac

# 写入文件
OUTPUT_FILE="$CONTENT_DIR/_index.md"
echo "$CONTENT" > "$OUTPUT_FILE"

print_success "文章创建成功!"
print_info "文件位置: $OUTPUT_FILE"
print_info ""
print_info "下一步操作:"
print_info "1. 编辑文章: vim '$OUTPUT_FILE'"
print_info "2. 本地预览: hugo server -D"
print_info "3. 发布文章: 将draft改为false并提交"

# 如果配置了编辑器，自动打开
if command -v code &> /dev/null; then
    read -p "是否用VSCode打开文件? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        code "$OUTPUT_FILE"
    fi
elif command -v vim &> /dev/null; then
    read -p "是否用vim打开文件? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        vim "$OUTPUT_FILE"
    fi
fi
