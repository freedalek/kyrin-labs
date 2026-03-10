// Obsidian Templater 脚本
// 用于快速创建Hugo文章

module.exports = {
    // 创建新文章
    async createHugoArticle(app, params) {
        const { moment, vault, adapter } = app;
        
        // 获取用户输入
        const title = await params.app.prompt("请输入文章标题：");
        if (!title) return;
        
        // 选择文章类型
        const type = await params.app.prompt(
            "请选择文章类型：",
            {
                buttons: [
                    { text: "博客文章", value: "blog" },
                    { text: "案例研究", value: "case" },
                    { text: "技术分享", value: "techshare" }
                ]
            }
        );
        
        if (!type) return;
        
        // 获取其他信息
        const tagsInput = await params.app.prompt("请输入标签（用逗号分隔）：");
        const category = await params.app.prompt("请输入分类：");
        const series = await params.app.prompt("请输入系列名称（可选）：");
        const summary = await params.app.prompt("请输入文章摘要：");
        
        // 生成slug
        const slug = title
            .toLowerCase()
            .replace(/[^a-z0-9\u4e00-\u9fa5]/g, '-')
            .replace(/-+/g, '-')
            .replace(/^-|-$/g, '');
        
        const date = moment().format("YYYY-MM-DD");
        const year = moment().format("YYYY");
        
        // 确定文件路径
        let filePath;
        let templateName;
        
        switch(type) {
            case "blog":
                filePath = `网站内容/博客文章/${year}/${slug}.md`;
                templateName = "blog_template.md";
                break;
            case "case":
                filePath = `网站内容/案例研究/${slug}.md`;
                templateName = "case_template.md";
                break;
            case "techshare":
                filePath = `网站内容/技术分享/${slug}.md`;
                templateName = "techshare_template.md";
                break;
        }
        
        // 读取模板
        const templatePath = `templates/${templateName}`;
        let templateContent;
        
        try {
            templateContent = await adapter.read(templatePath);
        } catch (error) {
            new Notice(`模板文件不存在: ${templatePath}`);
            return;
        }
        
        // 替换模板变量
        let content = templateContent
            .replace(/{{title}}/g, title)
            .replace(/{{date}}/g, date)
            .replace(/{{update_date}}/g, date)
            .replace(/{{slug}}/g, slug)
            .replace(/{{author}}/g, params.user?.name || "Your Name")
            .replace(/{{summary}}/g, summary || `这是关于 ${title} 的文章。`)
            .replace(/{{tags}}/g, tagsInput || "技术,学习")
            .replace(/{{categories}}/g, category || "未分类")
            .replace(/{{series}}/g, series || "");
        
        // 根据类型替换特定变量
        switch(type) {
            case "blog":
                content = content
                    .replace(/{{featured_image}}/g, `blog-${slug}.jpg`)
                    .replace(/{{language}}/g, "javascript")
                    .replace(/{{keywords}}/g, tagsInput || "技术,学习");
                break;
            case "case":
                content = content
                    .replace(/{{featured_image}}/g, `case-${slug}.jpg`)
                    .replace(/{{difficulty}}/g, "中级")
                    .replace(/{{time}}/g, "30分钟")
                    .replace(/{{case_type}}/g, "安全分析")
                    .replace(/{{technologies}}/g, "相关技术栈")
                    .replace(/{{language}}/g, "python");
                break;
            case "techshare":
                content = content
                    .replace(/{{featured_image}}/g, `techshare-${slug}.jpg`)
                    .replace(/{{type}}/g, "tool")
                    .replace(/{{version}}/g, "1.0.0")
                    .replace(/{{license}}/g, "MIT")
                    .replace(/{{github_url}}/g, `https://github.com/yourusername/${slug}`)
                    .replace(/{{language}}/g, "bash");
                break;
        }
        
        // 创建文件
        try {
            await vault.create(filePath, content);
            new Notice(`文章创建成功: ${filePath}`);
            
            // 打开新创建的文件
            const file = vault.getAbstractFileByPath(filePath);
            if (file) {
                const leaf = app.workspace.getLeaf();
                await leaf.openFile(file);
            }
        } catch (error) {
            new Notice(`创建文件失败: ${error.message}`);
        }
    },
    
    // 插入Front Matter模板
    async insertFrontMatter(app, params) {
        const { moment } = app;
        
        const frontMatter = `---
title: "{{title}}"
date: ${moment().format("YYYY-MM-DDTHH:mm:ss+08:00")}
draft: true
tags: ["技术", "学习"]
categories: ["技术博客"]
summary: "文章摘要"
---

`;
        
        // 获取当前文件
        const activeFile = app.workspace.getActiveFile();
        if (!activeFile) {
            new Notice("没有打开的文件");
            return;
        }
        
        // 读取文件内容
        const content = await app.vault.read(activeFile);
        
        // 检查是否已有front matter
        if (content.startsWith("---\n")) {
            new Notice("文件已有Front Matter");
            return;
        }
        
        // 插入front matter
        await app.vault.modify(activeFile, frontMatter + content);
        new Notice("Front Matter已插入");
    },
    
    // 插入代码块
    async insertCodeBlock(app, params) {
        const language = await app.prompt("请输入编程语言：", {
            defaultValue: "javascript"
        });
        
        if (!language) return;
        
        const codeBlock = `\n\n\`\`\`${language}\n// 你的代码在这里\n\`\`\`\n`;
        
        // 插入到当前光标位置
        await params.app.commands.executeCommandById("editor:insert-text", {
            text: codeBlock
        });
    },
    
    // 插入图片引用
    async insertImageLink(app, params) {
        const imageName = await app.prompt("请输入图片文件名：", {
            defaultValue: "example.jpg"
        });
        
        if (!imageName) return;
        
        const altText = await app.prompt("请输入图片描述：", {
            defaultValue: "图片描述"
        });
        
        const imageLink = `\n\n![${altText}](/0x04_archives/images/${imageName})\n`;
        
        await params.app.commands.executeCommandById("editor:insert-text", {
            text: imageLink
        });
    },
    
    // 插入表格模板
    async insertTableTemplate(app, params) {
        const rows = await app.prompt("请输入表格行数：", {
            defaultValue: "3"
        });
        
        const cols = await app.prompt("请输入表格列数：", {
            defaultValue: "3"
        });
        
        if (!rows || !cols) return;
        
        let table = "\n\n";
        
        // 表头
        table += "| ";
        for (let i = 1; i <= cols; i++) {
            table += `列${i} | `;
        }
        table += "\n";
        
        // 分隔线
        table += "| ";
        for (let i = 1; i <= cols; i++) {
            table += "--- | ";
        }
        table += "\n";
        
        // 数据行
        for (let i = 1; i <= rows; i++) {
            table += "| ";
            for (let j = 1; j <= cols; j++) {
                table += `行${i}列${j} | `;
            }
            table += "\n";
        }
        
        table += "\n";
        
        await params.app.commands.executeCommandById("editor:insert-text", {
            text: table
        });
    },
    
    // 插入提示框
    async insertCallout(app, params) {
        const type = await app.prompt("请选择提示框类型：", {
            buttons: [
                { text: "提示", value: "tip" },
                { text: "注意", value: "note" },
                { text: "警告", value: "warning" },
                { text: "重要", value: "important" }
            ]
        });
        
        if (!type) return;
        
        const content = await app.prompt("请输入提示内容：");
        
        if (!content) return;
        
        const callout = `\n\n:::${type}\n${content}\n:::\n`;
        
        await params.app.commands.executeCommandById("editor:insert-text", {
            text: callout
        });
    },
    
    // 批量操作：为多个文件添加front matter
    async batchAddFrontMatter(app, params) {
        const files = app.vault.getMarkdownFiles();
        
        // 过滤没有front matter的文件
        const filesWithoutFrontMatter = [];
        
        for (const file of files) {
            const content = await app.vault.read(file);
            if (!content.startsWith("---")) {
                filesWithoutFrontMatter.push(file);
            }
        }
        
        if (filesWithoutFrontMatter.length === 0) {
            new Notice("所有文件都有Front Matter");
            return;
        }
        
        const confirm = await app.prompt(
            `找到 ${filesWithoutFrontMatter.length} 个没有Front Matter的文件，是否继续？`,
            { buttons: ["是", "否"] }
        );
        
        if (confirm !== "是") return;
        
        let count = 0;
        for (const file of filesWithoutFrontMatter) {
            try {
                const content = await app.vault.read(file);
                const title = file.basename;
                const date = moment(file.stat.ctime).format("YYYY-MM-DDTHH:mm:ss+08:00");
                
                const frontMatter = `---\ntitle: "${title}"\ndate: ${date}\ndraft: true\ntags: ["未分类"]\ncategories: ["未分类"]\nsummary: ""\n---\n\n`;
                
                await app.vault.modify(file, frontMatter + content);
                count++;
            } catch (error) {
                console.error(`处理文件 ${file.path} 时出错:`, error);
            }
        }
        
        new Notice(`已为 ${count} 个文件添加Front Matter`);
    }
};
