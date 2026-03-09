+++
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | title }}'

# Case Study Fields
tldr = ""
background = ""
investigation_process = ""
evidence = ""
root_cause = ""
impact = ""
mitigation = ""
lessons_learned = ""

# Taxonomy
tags = []
categories = []
series = []
+++

## TL;DR

{{< placeholder text="简短的摘要，说明这个案例的核心发现" >}}

## Background

{{< placeholder text="背景介绍：事件概述、时间线、涉及的系统/人员" >}}

## Investigation Process

### 阶段一：发现与分析

{{< placeholder text="描述调查的初始发现和分析过程" >}}

### 阶段二：深入调查

{{< placeholder text="描述深入调查的细节和关键转折点" >}}

## Evidence

{{< placeholder text="列出关键证据，包括日志、流量、文件等" >}}

## Root Cause

{{< placeholder text="分析根本原因" >}}

## Impact

{{< placeholder text="评估影响范围和严重程度" >}}

## Mitigation

{{< placeholder text="描述缓解措施和修复方案" >}}

## Lessons Learned

{{< placeholder text="总结经验教训和改进建议" >}}

---

*Tags: {{< template "tags" >}}*
