# 密码相关异常处理

对应文件：`lib/model/password_exceptions.dart`

当获取数据过程中遇到密码相关错误时，需抛出该异常。

该类异常处理包括以下两类：

 - `NoPasswordException`：程序中尚未设置该服务相关密码；
 - `WrongPasswordException`：经程序认证，该服务相关密码有误。

从 `PasswordType` 可知该类异常针对以下几类服务：

 - `ids`：统一认证服务；
 - `physicsExperiment`：物理实验服务；
 - `sport`：体育查询服务；
 - `electricity`：电费查询服务，宿舍电费账号对应的密码；
 - `schoolnet`：校园网查询密码。