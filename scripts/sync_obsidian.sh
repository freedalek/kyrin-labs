#!/bin/bash

# ============================================
# Obsidian到Hugo同步脚本
# 将Obsidian中的Markdown文件同步到Hugo content目录
# ============================================

set -e  # 遇到错误退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量（根据实际情况修改）
OBSIDIAN_VAULT="$HOME/Obsidian Vaults/MyVault"  # Obsidian库路径
HUGO_CONTENT="content"                          # Hugo content目录
SYNC_LOG="logs/sync.log"                        # 同步日志
BACKUP_DIR="backups"                            # 备份目录

# 创建必要的目录
mkdir -p "$(dirname "$SYNC_LOG")" "$BACKUP_DIR"

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$SYNC_LOG"
}

log_info() {
    log "INFO" "$1"
}

log_success() {
    log "SUCCESS" "$1"
}

log_warning() {
    log "WARNING" "$1"
}

log_error() {
    log "ERROR" "$1"
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  sync      同步Obsidian内容到Hugo (默认)"
    echo "  backup    备份当前Hugo content目录"
    echo "  restore   从备份恢复"
    echo "  dry-run   试运行，不实际执行"
    echo "  clean     清理临时文件和缓存"
    echo "  status    显示同步状态"
    echo "  -h, --help 显示帮助信息"
    echo ""
    echo "配置说明:"
    echo "  请修改脚本开头的配置变量:"
    echo "  OBSIDIAN_VAULT: Obsidian库路径"
    echo "  HUGO_CONTENT: Hugo content目录"
}

# 检查路径是否存在
check_paths() {
    if [[ ! -d "$OBSIDIAN_VAULT" ]]; then
        log_error "Obsidian库不存在: $OBSIDIAN_VAULT"
        return 1
    fi
    
    if [[ ! -d "$HUGO_CONTENT" ]]; then
        log_warning "Hugo content目录不存在: $HUGO_CONTENT"
        read -p "是否创建目录? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p "$HUGO_CONTENT"
            log_success "创建目录: $HUGO_CONTENT"
        else
            return 1
        fi
    fi
    
    return 0
}

# 备份当前内容
backup_content() {
    local backup_name="content_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log_info "开始备份当前content目录..."
    
    if tar -czf "$backup_path" "$HUGO_CONTENT" 2>/dev/null; then
        log_success "备份成功: $backup_path"
        echo "备份文件: $(du -h "$backup_path" | cut -f1)"
        
        # 清理旧备份（保留最近7天）
        find "$BACKUP_DIR" -name "content_*.tar.gz" -mtime +7 -delete 2>/dev/null
        log_info "已清理7天前的旧备份"
    else
        log_error "备份失败"
        return 1
    fi
}

# 从备份恢复
restore_backup() {
    local backup_files=("$BACKUP_DIR"/content_*.tar.gz)
    
    if [[ ${#backup_files[@]} -eq 0 ]]; then
        log_error "没有找到备份文件"
        return 1
    fi
    
    echo "可用的备份文件:"
    for i in "${!backup_files[@]}"; do
        echo "  $((i+1)). ${backup_files[$i]##*/}"
    done
    
    read -p "选择要恢复的备份编号 (1-${#backup_files[@]}): " choice
    
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ $choice -lt 1 ]] || [[ $choice -gt ${#backup_files[@]} ]]; then
        log_error "无效的选择"
        return 1
    fi
    
    local selected_backup="${backup_files[$((choice-1))]}"
    
    log_info "正在从备份恢复: ${selected_backup##*/}"
    
    # 备份当前内容
    backup_content
    
    # 清空当前目录并恢复
    rm -rf "$HUGO_CONTENT"
    mkdir -p "$HUGO_CONTENT"
    
    if tar -xzf "$selected_backup" -C .; then
        log_success "恢复成功"
    else
        log_error "恢复失败"
        return 1
    fi
}

# 转换Obsidian语法到Hugo兼容格式
convert_obsidian_markdown() {
    local input_file="$1"
    local output_file="$2"
    
    # 读取文件内容
    local content=$(cat "$input_file")
    
    # 1. 转换双链 [[link]] -> [link](link)
    content=$(echo "$content" | sed -E 's/\[\[([^\|\]]+)(\|[^\]]+)?\]\]/[\1](\/\1)/g')
    
    # 2. 转换标签 #tag -> tags: ["tag"] (在front matter中处理)
    
    # 3. 转换callout语法
    content=$(echo "$content" | sed -E 's/^> \[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/:::{\L\1}/g')
    content=$(echo "$content" | sed 's/^> \[!INFO\]/:::info/g')
    content=$(echo "$content" | sed 's/^>$/:::/g')
    
    # 4. 转换图片链接 ![[image.png]] -> ![](/images/image.png)
    content=$(echo "$content" | sed -E 's/!\[\[([^\]]+)\]\]/![](\/0x04_archives\/images\/\1)/g')
    
    # 5. 保持front matter不变
    if [[ "$content" =~ ^--- ]]; then
        # 提取front matter
        local front_matter=$(echo "$content" | awk '/^---/{i++}i==1{print}i==2{print; exit}')
        local body_content=$(echo "$content" | awk 'BEGIN{p=0} /^---/{p++} p>=2{print}')
        
        # 处理front matter中的标签
        if [[ "$front_matter" =~ tags:[[:space:]]*\[.*\] ]]; then
            # 已经有tags，保持不变
            :
        else
            # 从内容中提取标签并添加到front matter
            local tags=$(echo "$body_content" | grep -o '#[a-zA-Z0-9_-]\+' | sed 's/^#//' | sort -u | tr '\n' ',' | sed 's/,$//')
            if [[ -n "$tags" ]]; then
                front_matter=$(echo "$front_matter" | sed "/^---/a tags: [\"${tags//,/'", "'}\"]")
            fi
        fi
        
        # 重新组合内容
        content="$front_matter\n$body_content"
    fi
    
    # 写入输出文件
    echo "$content" > "$output_file"
}

# 同步函数
sync_content() {
    local dry_run="$1"
    
    log_info "开始同步内容..."
    log_info "Obsidian库: $OBSIDIAN_VAULT"
    log_info "Hugo目录: $HUGO_CONTENT"
    
    # 映射关系
    declare -A dir_mapping=(
        ["网站内容/案例研究"]="0x00_Cases"
        ["网站内容/博客文章"]="0x01_Blogs"
        ["网站内容/方法论"]="0x02_Methodology"
        ["网站内容/技术分享"]="0x03_TechShare"
        ["网站内容/归档"]="0x04_archives"
        ["网站内容/关于"]="0xff_About"
    )
    
    local total_files=0
    local synced_files=0
    local skipped_files=0
    
    # 遍历映射关系
    for obsidian_dir in "${!dir_mapping[@]}"; do
        local hugo_dir="${dir_mapping[$obsidian_dir]}"
        local source_dir="$OBSIDIAN_VAULT/$obsidian_dir"
        local target_dir="$HUGO_CONTENT/$hugo_dir"
        
        if [[ ! -d "$source_dir" ]]; then
            log_warning "源目录不存在: $source_dir"
            continue
        fi
        
        log_info "同步: $obsidian_dir -> $hugo_dir"
        
        # 创建目标目录
        mkdir -p "$target_dir"
        
        # 查找所有markdown文件
        while IFS= read -r -d '' file; do
            ((total_files++))
            
            local rel_path="${file#$source_dir/}"
            local target_file="$target_dir/$rel_path"
            local target_dir_path="$(dirname "$target_file")"
            
            # 创建目标目录
            mkdir -p "$target_dir_path"
            
            # 检查是否需要同步
            local need_sync=false
            if [[ ! -f "$target_file" ]]; then
                need_sync=true
                log_info "新文件: $rel_path"
            elif [[ "$file" -nt "$target_file" ]]; then
                need_sync=true
                log_info "更新文件: $rel_path"
            fi
            
            if [[ "$need_sync" = true ]]; then
                if [[ "$dry_run" = true ]]; then
                    log_info "[试运行] 将同步: $rel_path"
                else
                    # 转换并复制文件
                    convert_obsidian_markdown "$file" "$target_file"
                    ((synced_files++))
                    log_success "同步: $rel_path"
                fi
            else
                ((skipped_files++))
            fi
            
        done < <(find "$source_dir" -name "*.md" -type f -print0)
    done
    
    # 复制图片等资源文件
    log_info "同步资源文件..."
    local resources_dir="$OBSIDIAN_VAULT/网站内容/归档"
    local target_resources="$HUGO_CONTENT/0x04_archives"
    
    if [[ -d "$resources_dir" ]]; then
        if [[ "$dry_run" = true ]]; then
            log_info "[试运行] 将同步资源文件"
        else
            rsync -av --ignore-existing "$resources_dir/" "$target_resources/" 2>/dev/null || true
            log_success "资源文件同步完成"
        fi
    fi
    
    # 生成同步报告
    log_info "\n同步完成!"
    log_info "总文件数: $total_files"
    log_info "同步文件: $synced_files"
    log_info "跳过文件: $skipped_files"
    
    if [[ "$dry_run" = true ]]; then
        log_warning "这是试运行，没有实际修改文件"
    fi
}

# 清理函数
cleanup() {
    log_info "开始清理..."
    
    # 清理Hugo缓存
    if command -v hugo &> /dev/null; then
        hugo --gc 2>/dev/null && log_success "清理Hugo缓存"
    fi
    
    # 清理临时文件
    find . -name "*.tmp" -delete 2>/dev/null
    find . -name "*.bak" -delete 2>/dev/null
    
    log_success "清理完成"
}

# 状态检查
check_status() {
    log_info "系统状态检查"
    echo ""
    
    # 检查目录
    echo "目录状态:"
    echo "  Obsidian库: $(if [ -d "$OBSIDIAN_VAULT" ]; then echo "✓ 存在"; else echo "✗ 不存在"; fi)"
    echo "  Hugo content: $(if [ -d "$HUGO_CONTENT" ]; then echo "✓ 存在"; else echo "✗ 不存在"; fi)"
    echo ""
    
    # 检查文件数量
    if [[ -d "$OBSIDIAN_VAULT" ]]; then
        local obsidian_files=$(find "$OBSIDIAN_VAULT/网站内容" -name "*.md" -type f 2>/dev/null | wc -l)
        echo "Obsidian文件数: $obsidian_files"
    fi
    
    if [[ -d "$HUGO_CONTENT" ]]; then
        local hugo_files=$(find "$HUGO_CONTENT" -name "*.md" -type f 2>/dev/null | wc -l)
        echo "Hugo文件数: $hugo_files"
    fi
    echo ""
    
    # 检查备份
    local backup_count=$(find "$BACKUP_DIR" -name "*.tar.gz" -type f 2>/dev/null | wc -l)
    echo "备份文件数: $backup_count"
    if [[ $backup_count -gt 0 ]]; then
        echo "最新备份: $(ls -t "$BACKUP_DIR"/content_*.tar.gz 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo "无")"
    fi
    echo ""
    
    # 检查日志
    if [[ -f "$SYNC_LOG" ]]; then
        echo "同步日志: $SYNC_LOG"
        echo "最后同步: $(tail -1 "$SYNC_LOG" 2>/dev/null | cut -d' ' -f1-2 || echo "从未同步")"
    fi
}

# 主函数
main() {
    local action="sync"
    local dry_run=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            sync|backup|restore|clean|status)
                action="$1"
                shift
                ;;
            dry-run)
                action="sync"
                dry_run=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 执行对应操作
    case $action in
        sync)
            if check_paths; then
                backup_content
                sync_content "$dry_run"
            fi
            ;;
        backup)
            backup_content
            ;;
        restore)
            restore_backup
            ;;
        clean)
            cleanup
            ;;
        status)
            check_status
            ;;
    esac
}

# 运行主函数
main "$@"
