# CI/CD 修复计划

## 执行摘要

本计划旨在修复 universal-devcontainer 项目中的 CI/CD 失败问题，确保所有 GitHub Actions workflows 符合官方最佳实践和安全标准。

**修复范围**: `.github/workflows/security-scan.yml`
**预计影响**: 3 个失败的 jobs 将恢复正常运行
**风险等级**: 低（只涉及配置修改，不改变扫描逻辑）

---

## 问题分析

### 问题 1: TruffleHog Secret Scan 失败 ❌
**位置**: `.github/workflows/security-scan.yml:116-132`

**当前配置**:
```yaml
- name: TruffleHog OSS
  uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    base: ${{ github.event.repository.default_branch }}  # "main"
    head: HEAD  # 在 main 分支 push 时也解析为 "main"
    extra_args: --debug --only-verified
```

**错误**:
```
BASE and HEAD commits are the same. TruffleHog won't scan anything.
```

**根本原因**:
- 在 main 分支的 push 事件中，`default_branch` 和 `HEAD` 都解析为 "main"
- TruffleHog 需要两个不同的 commit 引用来创建扫描范围
- 当 BASE == HEAD 时，没有差异可扫描，导致 action 失败退出

**官方文档参考**:
- TruffleHog 会自动处理 push 事件，使用 `github.event.after` 和 `github.event.before`
- 手动设置 `base` 和 `head` 仅用于特殊场景
- 文档来源: [TruffleHog GitHub Action](https://github.com/trufflesecurity/trufflehog/blob/main/action.yml)

---

### 问题 2: Trivy SARIF 上传权限不足 ❌
**位置**: `.github/workflows/security-scan.yml:20-76, 84-106`

**当前配置**:
```yaml
# Workflow 顶层
permissions:
  contents: read  # ❌ 只读权限

jobs:
  trivy-scan:
    # ❌ 没有 job 级别权限覆盖
    steps:
      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v3  # 需要 security-events: write
        with:
          sarif_file: 'trivy-results.sarif'
```

**错误**:
```
Resource not accessible by integration
This run does not have permission to access CodeQL Action API endpoints
```

**根本原因**:
- 上传 SARIF 到 GitHub Security tab 需要 `security-events: write` 权限
- Workflow 顶层设置为 `contents: read`，没有在 job 级别添加必要权限
- 其他 jobs（如 `security-scorecard`）有正确配置但 Trivy jobs 没有

**官方文档参考**:
- SARIF 上传必须有 `security-events: write` 权限
- 最佳实践：顶层最小权限 + job 级别按需覆盖
- 文档来源: [GitHub SARIF Upload Docs](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/uploading-a-sarif-file-to-github)

---

### 问题 3: Dependency Review Workflow 失败 ⚠️
**位置**: `.github/workflows/dependency-review.optional.yml`

**状态**: 这不是真正的错误

**说明**:
- 文件名为 `.optional.yml`，不是标准 GitHub Actions 文件扩展名
- 文件头部注释明确说明这是可选功能
- 需要启用 Dependency graph（需要管理员权限）
- 需要 GitHub Advanced Security 许可证（私有仓库）

**建议**: 保持现状，不需要修复

---

## 修复方案

### 方案 1: 修复 TruffleHog 配置 ✅

**策略**: 移除手动的 `base` 和 `head` 参数，让 TruffleHog 自动处理事件

**优点**:
- ✅ 符合官方推荐配置
- ✅ 自动处理所有事件类型（push, pull_request, schedule）
- ✅ 更简洁，减少配置错误
- ✅ 无需针对不同事件类型编写条件逻辑

**修改内容**:
```yaml
# 修改前
- name: TruffleHog OSS
  uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    base: ${{ github.event.repository.default_branch }}  # ❌ 删除
    head: HEAD  # ❌ 删除
    extra_args: --debug --only-verified

# 修改后
- name: TruffleHog OSS
  uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    extra_args: --debug --only-verified
    # base 和 head 由 action 自动处理
```

**工作原理**:
- Push 事件: 自动扫描 `github.event.before` 到 `github.event.after` 的变更
- Pull Request 事件: 自动扫描 PR 的差异
- Schedule/Manual 事件: 扫描整个仓库

**参考**: [TruffleHog GitHub Actions Example](https://github.com/trufflesecurity/trufflehog-github-actions-example/blob/main/.github/workflows/test.yml)

---

### 方案 2: 添加 Security Events 权限 ✅

**策略**: 遵循最小权限原则，在需要的 jobs 上添加 `security-events: write` 权限

**优点**:
- ✅ 符合 GitHub 安全最佳实践
- ✅ 保持顶层最小权限（defense in depth）
- ✅ 仅给需要的 jobs 授予必要权限
- ✅ 与现有 `security-scorecard` job 的模式一致

**修改内容**:
```yaml
jobs:
  trivy-scan:
    name: Trivy Vulnerability Scan
    runs-on: ubuntu-latest
    permissions:  # ✅ 添加 job 级别权限
      contents: read
      security-events: write  # 允许上传 SARIF
    steps:
      # ...现有步骤

  trivy-fs-scan:
    name: Trivy Filesystem Scan
    runs-on: ubuntu-latest
    permissions:  # ✅ 添加 job 级别权限
      contents: read
      security-events: write  # 允许上传 SARIF
    steps:
      # ...现有步骤
```

**验证模式**: 参考现有的 `security-scorecard` job (行 134-166):
```yaml
security-scorecard:
  permissions:
    security-events: write  # ✅ 正确配置
    id-token: write
    contents: read
```

**参考**:
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Trivy Action Examples](https://github.com/aquasecurity/trivy-action)

---

### 方案 3: 改进 SARIF 上传可靠性 ✅

**策略**: 确保即使扫描失败也能上传结果（已部分实现）

**当前状态**: ✅ 已经正确配置
```yaml
- name: Upload Trivy results to GitHub Security
  uses: github/codeql-action/upload-sarif@v3
  if: always()  # ✅ 正确
  with:
    sarif_file: 'trivy-results.sarif'
```

**验证**: 配置已符合官方建议，无需修改

**参考**: [Trivy Action Best Practices](https://github.com/aquasecurity/trivy-action#sarif)

---

## 实施计划

### 阶段 1: 准备和验证 ✅
- [x] 分析 CI/CD 失败日志
- [x] 研究官方文档和最佳实践
- [x] 制定详细修复计划
- [ ] 用户审核和批准计划

### 阶段 2: 执行修复
**预计时间**: 5 分钟
**风险**: 低

1. **修改 `.github/workflows/security-scan.yml`**
   - 移除 TruffleHog 的 `base` 和 `head` 参数
   - 为 `trivy-scan` job 添加 `permissions` 块
   - 为 `trivy-fs-scan` job 添加 `permissions` 块

2. **提交变更**
   ```bash
   git add .github/workflows/security-scan.yml
   git commit -m "fix: resolve CI/CD security scan failures"
   git push
   ```

### 阶段 3: 验证和测试
**预计时间**: 5-10 分钟（等待 GitHub Actions 运行）

1. **监控 Workflow 运行**
   - 验证 TruffleHog secret-scan job 成功
   - 验证 Trivy scans 成功上传 SARIF
   - 检查 GitHub Security tab 是否显示结果

2. **成功标准**
   - ✅ 所有 security-scan workflow jobs 状态为绿色
   - ✅ SARIF 结果显示在 Security > Code scanning 标签
   - ✅ 没有权限相关错误
   - ✅ TruffleHog 成功扫描变更

---

## 回滚计划

如果修复后出现新问题：

### 快速回滚
```bash
git revert HEAD
git push
```

### 临时禁用（如果需要）
将 workflow 重命名为 `.yml.disabled`:
```bash
mv .github/workflows/security-scan.yml .github/workflows/security-scan.yml.disabled
```

---

## 测试检查清单

执行修复后验证以下项目：

- [ ] `secret-scan` job 完成且状态为成功
- [ ] `trivy-scan` job 完成且状态为成功
- [ ] `trivy-fs-scan` job 完成且状态为成功
- [ ] 没有 "Resource not accessible" 错误
- [ ] 没有 "BASE and HEAD commits are the same" 错误
- [ ] GitHub Security tab 显示 Trivy 扫描结果
- [ ] Workflow summary 显示所有 jobs 成功

---

## 预期结果

### 修复前 ❌
```
✅ Test Dev Container: success
✅ Test Python Examples: success
❌ Security Scan: failure
  ├── ✅ trivy-scan: success (但 SARIF 上传失败)
  ├── ✅ trivy-fs-scan: success (但 SARIF 上传失败)
  ├── ❌ secret-scan: failure (BASE == HEAD)
  └── ✅ security-scorecard: success
❌ Dependency Review: failure (可选功能)
```

### 修复后 ✅
```
✅ Test Dev Container: success
✅ Test Python Examples: success
✅ Security Scan: success
  ├── ✅ trivy-scan: success (SARIF 上传成功)
  ├── ✅ trivy-fs-scan: success (SARIF 上传成功)
  ├── ✅ secret-scan: success (自动检测差异)
  └── ✅ security-scorecard: success
⚠️  Dependency Review: failure (可选功能，保持原状)
```

---

## 参考文档

### 官方文档
- [TruffleHog GitHub Action](https://github.com/trufflesecurity/trufflehog/blob/main/action.yml)
- [TruffleHog GitHub Actions Example](https://github.com/trufflesecurity/trufflehog-github-actions-example/blob/main/.github/workflows/test.yml)
- [GitHub: Uploading SARIF Files](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/uploading-a-sarif-file-to-github)
- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Trivy Action Documentation](https://github.com/aquasecurity/trivy-action)
- [GitHub Actions Permissions](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)

### 最佳实践文章
- [GitHub Actions Security Best Practices](https://www.stepsecurity.io/blog/github-actions-security-best-practices)
- [Running TruffleHog in GitHub Actions](https://trufflesecurity.com/blog/running-trufflehog-in-a-github-action)

---

## 附录：权限对照表

| Job | 当前权限 | 需要权限 | 状态 |
|-----|---------|---------|------|
| trivy-scan | contents: read (继承) | security-events: write | ❌ 需要修复 |
| trivy-fs-scan | contents: read (继承) | security-events: write | ❌ 需要修复 |
| secret-scan | contents: read (继承) | contents: read | ✅ 权限正确 |
| security-scorecard | security-events: write ✅ | security-events: write | ✅ 配置正确 |

---

## 联系和支持

**问题追踪**:
- 本次修复相关问题可在 GitHub Issues 中讨论
- 参考 CI/CD 运行日志和本计划文档

**修复执行者**: Claude Code
**审核者**: 项目维护者
**修复日期**: 待定
