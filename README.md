# 哪吒一键V0注册脚本

这是一个用于注册哪吒面板节点的自动化脚本。支持通过命令行参数设置所有必要的配置信息。

## 使用方法

运行脚本时需要提供以下参数：
- `hostname`: 节点主机名（可选，默认使用系统主机名）
- `token`: 哪吒面板 Token（必需）
- `probe_address`: 探针服务器地址（必需）
- `dashboard_url`: 面板访问地址（必需）

```bash
# 使用示例
./nezha_register.sh \
  hostname=your-hostname \
  token=your-token \
  probe_address=probe.example.com \
  dashboard_url=https://nezha.example.com

# 使用系统默认主机名
./nezha_register.sh \
  token=your-token \
  probe_address=probe.example.com \
  dashboard_url=https://nezha.example.com
```

## 注意事项

- 所有参数都通过命令行传入，格式为 `参数名=参数值`
- 如果缺少必要参数，脚本会显示使用说明
- 建议在生产环境中使用 TLS 加密连接
