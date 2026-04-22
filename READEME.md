# 支付网关 JMeter 性能测试套件

本项目提供了一套完整的 JMeter 性能测试脚本，专为支付网关类接口设计，支持高并发压测、数据参数化、签名生成及多维度结果分析。

## 📁 项目结构

```
├── test-plans/                  # JMeter 测试计划主目录
│   └── 03-quick-pay.jmx         # 主测试脚本（500线程/30分钟并发测试）
├── test-data/                   # 测试数据目录
│   └── accounts.csv             # 参数化数据文件（卡号/手机号/银行代码）
├── scripts/                     # 辅助脚本目录
│   └── run-test.bat             # Windows 批处理执行脚本
├── reports/                     # 测试报告输出目录（结果存放位置）
├── mock_server.py               # Python Mock 服务器（本地调试用）
└── README.md                    # 项目说明文档
```

## 🚀 快速开始

### 环境要求

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| JDK | 11 或 17 | JMeter 5.6.3 官方推荐版本 |
| JMeter | 5.6.3+ | 从 [Apache JMeter 官网](https://jmeter.apache.org/download_jmeter.cgi) 下载 |
| Python | 3.7+ | 仅用于运行 Mock 服务器（可选） |

> ⚠️ 注意：Groovy 3.0.20 不支持 Java 25+，请使用 JDK 11 或 17。

### 测试数据准备

在 `test-data/accounts.csv` 文件中准备测试账号数据，格式如下：

```csv
card_no,phone,bank_code
6222021234567890123,13800138000,ICBC
6222021234567890124,13800138001,ICBC
6222021234567890125,13800138002,ICBC
```

## 🧪 测试执行

### 方式一：使用脚本执行（Windows）

```batch
cd scripts
run-test.bat
```

### 方式二：JMeter GUI 模式（调试）

1. 启动 JMeter GUI：`./bin/jmeter.bat`（Windows）或 `./bin/jmeter`（Mac/Linux）
2. 打开 `test-plans/03-quick-pay.jmx`
3. 设置线程数（建议调试时设为 5）、Ramp-up 时间 5 秒
4. 添加 **查看结果树** 监听器，点击绿色启动按钮运行
5. 检查响应是否为绿色（成功）或红色（失败），根据错误信息调整配置

### 方式三：JMeter 命令行模式（正式压测）

```bash
cd apache-jmeter-5.6.3

# 创建报告目录
mkdir -p reports/$(date +%Y%m%d_%H%M%S)
REPORT_DIR="reports/$(date +%Y%m%d_%H%M%S)"

# 执行测试（非 GUI 模式）
./bin/jmeter -n \
  -t /path/to/03-quick-pay.jmx \
  -l ${REPORT_DIR}/result.jtl \
  -e -o ${REPORT_DIR}/dashboard \
  -Jthreads=500 -Jrampup=60 -Jduration=1800
```

**参数说明**：

| 参数 | 说明 |
|------|------|
| `-n` | 非 GUI 模式运行 |
| `-t` | 指定测试计划文件路径 |
| `-l` | 指定结果文件（.jtl）路径 |
| `-e -o` | 测试结束后生成 HTML 报告并输出到指定目录 |
| `-J` | 动态覆盖 JMeter 属性（线程数/启动时间/持续时间） |

### 使用 Mock 服务器进行本地调试

```bash
# 启动 Mock 服务器
python mock_server.py

# 修改 JMeter 测试计划中的目标地址为 localhost:8080
```

## 📊 查看测试报告

### 方式一：HTML Dashboard 报告

命令行执行完成后，打开报告目录中的 `index.html`：

```bash
open ${REPORT_DIR}/dashboard/index.html   # Mac
start ${REPORT_DIR}/dashboard/index.html  # Windows
```

**关键图表说明**：

| 图表 | 说明 | 健康标准 |
|------|------|----------|
| Transactions Per Second | 每秒事务数 | 平稳无断崖下跌 |
| Response Times Over Time | 响应时间趋势 | P95 < 800ms |
| Active Threads Over Time | 活跃线程数 | 与配置一致 |
| Response Time Percentiles | 百分位分布 | P99 < 2000ms |
| Errors | 错误统计 | 必须为 0 |

### 方式二：聚合报告

在 JMeter GUI 中添加 **聚合报告（Aggregate Report）** 监听器，加载 `.jtl` 结果文件，可查看以下关键指标：

| 指标 | 说明 |
|------|------|
| **Samples** | 总请求数 |
| **Average** | 平均响应时间（ms） |
| **Error %** | 错误率（%） |
| **Throughput** | 吞吐量（请求数/秒） |

## 🛠 技术栈

- **Apache JMeter 5.6.3**：核心性能测试工具
- **Groovy**：JSR223 前置处理器，用于动态生成订单号、金额和签名
- **Python**：Mock 服务器，模拟支付网关响应
- **InfluxDB**：后端监听器，支持实时数据写入（可选）

## 📝 常见问题

### 1. 查看结果树中没有“发起支付”请求？

**原因**：JSR223 前置处理器编译失败，线程提前终止。通常是 JDK 版本过高导致 Groovy 无法解析。

**解决方案**：
- 检查 JDK 版本（`java -version`），建议降级到 **JDK 11** 或 **JDK 17**
- 设置 `JAVA_HOME` 环境变量指向正确版本，重启 JMeter
- 查看日志文件 `jmeter.log` 确认 Groovy 错误信息

### 2. JSON 提取器提示“json can not be null or empty”？

**原因**：登录接口返回空响应或非 JSON 格式。

**解决方案**：
- 检查登录请求的 URL、端口、路径是否正确
- 在登录请求下临时添加 **查看结果树**，查看实际响应内容
- 确认 JSON Path 表达式 `$.data.token` 与响应结构匹配

### 3. “发起支付”只执行一次，没有循环？

**原因**：循环控制器的循环次数未正确设置。

**解决方案**：
- 选中 **循环控制器：支付流程**
- 在右侧属性面板中勾选 **永远（Infinite）**，或输入 `-1`
- 如果使用固定次数，取消勾选“永远”并输入具体数字（如 `100`）


## 📌 后续计划

- [ ] 支持分布式压测（多台 JMeter 负载机）
- [ ] 集成 GitHub Actions 实现 CI/CD 自动压测
- [ ] 添加 Grafana + InfluxDB 实时监控看板
- [ ] 支持更多签名算法（RSA、HMAC-SHA256）

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add some amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 打开 Pull Request

## 📄 许可证

本项目仅供学习研究使用。

--