# Redmine Autologin API 插件集成文档

## 概述

已成功开发并部署 Redmine 插件，实现了云平台与 Redmine 的完全解耦。

## 架构变化

### 之前（直连数据库）
```
CloudStudio → Redmine 数据库 → 直接操作 users/tokens 表
耦合度: 80%
```

### 现在（API 方案）
```
CloudStudio → Redmine REST API → 用户管理
CloudStudio → Redmine 插件 API → Token 管理
耦合度: 0%（完全解耦）
```

## 插件信息

- **名称**: redmine_autologin_api
- **版本**: 1.0.0
- **位置**: `/usr/src/redmine/plugins/redmine_autologin_api/`
- **状态**: ✅ 已安装并运行

## API 接口

### 1. 生成 autologin token
```bash
POST /api/autologin_tokens.json
Headers:
  X-Redmine-API-Key: {管理员 API Key}
  Content-Type: application/json
Body:
  {"user_id": 123}

Response:
{
  "success": true,
  "user_id": 123,
  "login": "user@example.com",
  "token": "abc123..."
}
```

### 2. 删除 autologin token
```bash
DELETE /api/autologin_tokens/{user_id}.json
Headers:
  X-Redmine-API-Key: {管理员 API Key}

Response:
{
  "success": true,
  "deleted_count": 1
}
```

### 3. 测试接口
```bash
GET /api/autologin_tokens/test.json

Response:
{
  "plugin": "redmine_autologin_api",
  "version": "1.0.0",
  "status": "ok"
}
```

## 云平台代码变更

### 新增文件

1. **RedmineApiClient.php** - Redmine API 客户端
   - 用户查询、创建、更新
   - Token 生成和删除

2. **RedmineAuthService.php** - 重构版（使用 API）
   - 完全通过 API 实现用户同步
   - 无数据库依赖

### 配置变更

**config/services.php**
```php
'redmine' => [
    'url' => env('REDMINE_URL', 'http://127.0.0.1:3000'),
    'api_key' => env('REDMINE_API_KEY'),
],
```

**环境变量（.env）**
```bash
REDMINE_URL=http://redmine:3000
REDMINE_API_KEY=1234567890abcdef1234567890abcdef12345678
```

## 测试结果

✅ 插件安装成功
✅ API 认证通过
✅ Token 生成成功
✅ Token 删除成功
✅ 用户查询成功

### 测试数据
- 管理员 API Key: `1234567890abcdef1234567890abcdef12345678`
- 测试用户 ID: 6 (fineyi)
- 生成的 Token: `39dbca26bfc83f751841bdf37e8a2f54a3fee7e6`

## 优势

1. **完全解耦**: 云平台不再依赖 Redmine 数据库结构
2. **易于维护**: Redmine 升级不影响云平台
3. **标准化**: 使用 REST API 规范
4. **安全性**: 通过 API Key 控制权限
5. **可扩展**: 未来可轻松接入其他系统

## 部署步骤

1. 确保 Redmine 容器运行
2. 插件已复制到 `/usr/src/redmine/plugins/redmine_autologin_api/`
3. 在 Redmine 管理后台启用 REST API
4. 为管理员生成 API Key
5. 配置云平台环境变量
6. 重启云平台服务

## 注意事项

- API Key 必须是管理员用户的
- REST API 必须在 Redmine 中启用
- 插件需要 Redmine >= 5.0.0
- Token 生成需要用户已存在（先通过标准 API 创建用户）

## 维护

- 插件代码简单，维护成本低
- Redmine 升级时测试插件兼容性
- 定期检查 API Key 有效性
