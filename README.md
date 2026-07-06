# 💕 不生气打卡

情侣双人打卡网站，记录每天和睦相处的日子。

## 🚀 线上地址

Netlify 永久部署：*(你的 Netlify 链接)*

## 🏗️ 技术栈

- **前端**：HTML + CSS + JS（单文件，部署到 Netlify）
- **后端**：Supabase（Auth 登录 + 数据库 + 文件存储）
- **Edge Function**：Supabase Edge Functions（密保重置密码）

## 📁 版本

| 版本 | 文件夹 | 说明 |
|------|--------|------|
| v1.0 | `versions/v1.0-初始化/` | 本地版，localStorage 存储，无需后端 |
| v2.0 | `versions/v2.0-账号系统/` | 当前版，Supabase 账号 + 双人打卡 + 月历 + 图片 + 密保 |

## 🛠️ 部署说明

### 第一次部署（完整步骤）

1. 创建 Supabase 项目 → 获取 API 密钥
2. 运行 `supabase-setup.sql` 初始化数据库
3. 部署 `reset-password` Edge Function
4. 修改 `index.html` 里的 `SUPABASE_URL` 和 `SUPABASE_ANON_KEY`
5. 上传到 Netlify

### 更新部署

只需重新上传 `index.html` 到 Netlify。**数据库数据不受影响。**

## 📦 文件结构

```
打卡网站/
├── index.html              ← 当前最新版
├── README.md               ← 本说明
├── supabase-setup.sql      ← 数据库建表脚本
├── supabase/
│   └── functions/
│       └── reset-password/ ← 密保重置 Edge Function
└── versions/
    ├── v1.0-初始化/
    │   ├── index.html
    │   └── README.md
    └── v2.0-账号系统/
        ├── index.html
        ├── README.md
        └── supabase-setup.sql
```
