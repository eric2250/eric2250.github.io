## 1.开启163邮箱POP3/SMTP服务 ##

- 登录邮箱-设置-POP3/SMTP/IMAP-POP3/SMTP服务已开启-获取授权码-MJQELDMMRGJZAHKH


## 2.jebkins配置-系统配置-最下面邮件通知 ##
-前提先设置 系统管理员邮件地址：gouwqiang@163.com

- SMTP服务器：smtp.163.com
- 用户默认邮件后缀：选填
- （✔）使用SMTP认证：
	- 用户名：gouwqiang@163.com
	- 密码：MJQELDMMRGJZAHKH 授权码
               AVUYJNHJCEBSPCZP
			
- SMTP端口：465 （勾选使用SSL协议）
- SMTP端口：25  （不勾选使用SSL协议）
- 字符集：UTF-8


（✔）通过发送测试邮件测试配置
	- Test e-mail recipient：gouwqiang@163.com
	- 点击 Test configuration
	- 返回 Email was successfully sent

## 3.配置流水线发送 ##
	mail to: 'gouwqiang@163.com',
    subject: "Successful Pipeline: ${currentBuild.fullDisplayName}",
    body: "Something is wrong with ${env.BUILD_URL}"

```
    emailext to: 'gouwqiang@163.com',
    subject: "Jenkins-${JOB_NAME}项目构建信息 ",
    body: """
            <!DOCTYPE html> 
            <html> 
            <head> 
            <meta charset="UTF-8"> 
            </head> 
            <body leftmargin="8" marginwidth="0" topmargin="8" marginheight="4" offset="0"> 
                <!--<img src="http://appweb.eric.com/web/k8s.jpg">-->
                <table width="95%" cellpadding="0" cellspacing="0" style="font-size: 11pt; font-family: Tahoma, Arial, Helvetica, sans-serif">   
                    <tr> 
                        <td><br /> 
                            <b><font color="#0B610B">构建信息</font></b> 
                        </td> 
                    </tr> 
                    <tr> 
                        <td> 
                            <ul> 
                                <li>项目名称：${JOB_NAME}</li>         
                                <li>构建编号：${BUILD_ID}</li> 
                                <li>构建状态: ${status} </li>                         
                                <li>项目地址：<a href="${BUILD_URL}">${BUILD_URL}</a></li>    
                                <li>构建日志：<a href="${BUILD_URL}console">${BUILD_URL}console</a></li> 
                            </ul> 
                        </td> 
                    </tr> 
                    <tr>  
                </table> 
            </body> 
            </html>  """  
```              