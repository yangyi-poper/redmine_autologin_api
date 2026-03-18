# Redmine Autologin API Plugin

为 Redmine 提供 autologin token 管理的 REST API，用于支持 SSO 单点登录集成。

## 功能

- 为指定用户生成 autologin token
- 删除用户的 autologin token
- 支持 API Key 认证
- 需要管理员权限

## 安装

1. 将插件复制到 Redmine 的 plugins 目录：
```bash
cp -r redmine_autologin_api /usr/src/redmine/plugins/
```

2. 重启 Redmine：
```bash
touch /usr/src/redmine/tmp/restart.txt
# 或
pkill -f puma
```

3. 验证插件已加载：
访问 Redmine 管理后台 -> 插件，查看是否有 "Redmine Autologin API Plugin"

## API 使用

### 1. 获取管理员 API Key

在 Redmine 中：我的账户 -> API 访问密钥 -> 显示

### 2. 生成 autologin token

```bash
curl -X POST http://redmine:3000/api/autologin_tokens.json \
  -H "X-Redmine-API-Key: YOUR_ADMIN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"user_id": 123}'
```

响应：
```json
{
  "success": true,
  "user_id": 123,
  "login": "user@example.com",
  "token": "abc123..."
}
```

注意：user_id 是 Redmine 用户 ID，需要先通过 Redmine 标准 API 查询或创建用户获取。

### 3. 删除 autologin token

```bash
curl -X DELETE http://redmine:3000/api/autologin_tokens/123.json \
  -H "X-Redmine-API-Key: YOUR_ADMIN_API_KEY"
```

### 4. 测试接口

```bash
curl http://redmine:3000/api/autologin_tokens/test.json \
  -H "X-Redmine-API-Key: YOUR_ADMIN_API_KEY"
```

## 安全说明

- 所有接口（除测试接口）都需要管理员权限
- 建议使用专用的管理员账号生成 API Key
- 建议在生产环境配置 IP 白名单

## 版本要求

- Redmine >= 5.0.0
- Ruby >= 2.7
- Rails >= 6.1

## License

MIT
