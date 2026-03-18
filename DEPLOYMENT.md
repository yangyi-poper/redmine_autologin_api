# Redmine SSO 完整部署步骤

## 1. 清理旧环境

```bash
# 停止并删除容器
docker stop redmine redmine-postgres
docker rm redmine redmine-postgres

# 删除持久化数据（重要！）
docker volume rm redmine-db-data redmine-files-data
```

## 2. 启动 Redmine 容器

```bash
cd /Users/young/Develop/www/poper/fangchang-cloudstudio
docker compose -f docker-compose-redmine.yml up -d
```

## 3. 连接容器到网络

```bash
# 连接到 CloudStudio 所在网络
docker network connect dnmp_v4_default redmine
docker network connect dnmp_v4_default redmine-postgres

# 验证网络连接
docker exec php82 ping -c 2 redmine
```

## 4. 安装 Redmine 插件

```bash
# 复制插件到容器
docker cp redmine_autologin_api redmine:/usr/src/redmine/plugins/

# 重启 Redmine
docker exec redmine touch /usr/src/redmine/tmp/restart.txt

# 等待 30 秒或手动重启
# docker exec redmine pkill -f puma

# 验证插件
docker exec redmine ls -la /usr/src/redmine/plugins/redmine_autologin_api
```

## 5. 配置 Redmine

### 5.1 访问 Redmine
http://redmine.fangchangkemao.local:3000

### 5.2 初始登录
- 用户名：admin
- 密码：admin

### 5.3 启用 REST API
管理 → 配置 → API → 勾选"启用 REST API"

### 5.4 生成 API Key
我的账户 → API 访问密钥 → 显示 → 复制 API Key

### 5.5 启用 Autologin（命令行方式）
```bash
docker exec redmine sh -c "cd /usr/src/redmine && bundle exec rails runner \"Setting.autologin = 7\""
```

或通过界面：管理 → 配置 → 认证 → 自动登录 → 选择"7天"

## 6. 配置 CloudStudio

### 6.1 更新 .env
```bash
REDMINE_API_URL=http://redmine:3000
REDMINE_PUBLIC_URL=http://redmine.fangchangkemao.local:3000
REDMINE_API_KEY=<刚才复制的 API Key>
```

### 6.2 清除缓存
```bash
docker exec php82 sh -c "cd /www/poper/fangchang-cloudstudio && php artisan config:clear && php artisan config:cache"
```

## 7. 测试

### 7.1 测试插件 API
```bash
docker exec php82 sh -c "curl -s -H 'X-Redmine-API-Key: <API_KEY>' http://redmine:3000/api/autologin_tokens/test.json"
```

### 7.2 测试 SSO 跳转
访问：http://cloud-studio.fangchangkemao.local/admin/redmine/redirect

应该自动跳转到 Redmine 并登录成功。

## 常见问题

### Q1: 跳转后没有登录
**原因**：Redmine autologin 功能未启用
**解决**：执行步骤 5.5

### Q2: API 返回 401
**原因**：API Key 无效或 REST API 未启用
**解决**：检查步骤 5.3 和 5.4

### Q3: Email is invalid 错误
**原因**：用户名不是邮箱格式
**解决**：代码已自动处理，会添加 @redmine.local 后缀

### Q4: 容器无法通信
**原因**：容器不在同一网络
**解决**：执行步骤 3
