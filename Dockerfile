# Dockerfile [grok生成]
# 第一阶段：构建 Node.js 应用（如果有前端需要构建）
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# 如果是纯后端可以跳过 build 步骤
RUN npm run build --if-present

# 第二阶段：最终镜像，包含 Nginx + Node.js
FROM node:20-alpine

# 安装 nginx
RUN apk add --no-cache nginx

# 复制自定义 nginx 配置
COPY nginx.conf /etc/nginx/http.d/default.conf

# 从 builder 阶段复制 node 应用
COPY --from=builder /app /app
WORKDIR /app

# 暴露 80 端口（Nginx 监听）
EXPOSE 80

# 创建启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 启动 Nginx 和 Node.js（使用 supervisord 或简单脚本）
# 这里用一个简单的 shell 脚本同时启动两者
ENTRYPOINT ["/start.sh"]
