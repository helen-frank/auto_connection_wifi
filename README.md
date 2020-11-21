# auto_connection_wifi

这个脚本是为了解决命令行连接wifi问题

情景：手上有一台笔记本安装了centos，作为个人小型服务器放置于社团使用（网和电不用担心），笔记本拥有无线网卡，wifi长久存在，但离路由器较远，网线连接不好铺设，于是通过wifi连接使用,于是写了这个脚本(auto_connection_wifi.sh)

又因为某些原因，wifi在每天的特定时间会停掉一段时间，于是写了个自动连接wifi的脚本(reconnection.sh)内置于auto_connection_wifi.sh中

### 运行方法

使用root账户登陆到服务器

将脚本复制到服务器上

chmod +x auto_connection_wifi.sh

./auto_connection_wifi.sh
