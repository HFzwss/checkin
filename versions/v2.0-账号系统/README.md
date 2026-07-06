# v2.0 - 账号系统版

## ✨ 功能

- 🔐 Supabase 邮箱登录/注册
- 💑 双人独立打卡，配对码绑定伴侣
- 📅 月历视图 + 点击编辑历史记录
- 📝 文字笔记 + 图片上传（自动压缩 1MB）
- 🔑 密保问题找回密码
- 🚫 10 次输错锁定 1 分钟
- ✏️ 点击昵称可修改
- 💍 每月 9 号纪念日特殊标记
- 📱 响应式设计，手机/电脑通用

## 🛠️ 部署

### 1. 创建 Supabase 项目
https://supabase.com → New Project

### 2. 初始化数据库
SQL Editor → 运行 `supabase-setup.sql`

### 3. 部署 Edge Function
Edge Functions → 新建 `reset-password` → 粘贴 `supabase/functions/reset-password/index.ts`

### 4. 配置前端
修改 `index.html` 顶部：
```js
const SUPABASE_URL = 'https://你的项目.supabase.co';
const SUPABASE_ANON_KEY = '你的 key';
```

### 5. 部署到 Netlify
拖拽 `index.html` 到 https://app.netlify.com/drop

## ⚙️ Supabase 设置
- **Auth → Settings**：关闭 Confirm email
- **SQL Editor**：运行 `supabase-setup.sql`
