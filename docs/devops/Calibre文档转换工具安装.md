Calibre 的配置与按照请参考官方文档：

- 下载地址：https://calibre-ebook.com/download
- 包下载：https://download.calibre-ebook.com
- 根据自己的系统安装对应的 calibre（需要注意的是，calibre 要安装 3.x 版本的，2.x 版本的功能不是很强大。反正安装最新的就好。) 
- 安装完 calibre 之后，将 calibre 加入到系统环境变量中，执行下面的命令之后显示 3.x 的版本即表示安装成功。

```SQL
ebook-convert --version
```

## 1. 安装

```Bash
 sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh --no-check-certificate | sudo sh /dev/stdin
 
 wget https://download.calibre-ebook.com/linux-installer.sh --no-check-certificate
 sh linux-installer.sh
 
 #ubuntu报错：
 ou are missing the system library libEGL.so.1. Try installing packages such as libegl1 and libopengl0
 # apt install -y libegl1 libopengl0
```

报 glibc 版本问题

升级[Linuxglibc升级](https://xlymqcg2kt.feishu.cn/docx/EvDRdbE0NolCMBxtfcFcQgFnnAc) 

## 2. 验证

```CSS
ebook-convert test.txt test.pdf

报错：
Init Parameters:
  *  application-name ebook-convert 
  *  browser-subprocess-path /opt/calibre/libexec/QtWebEngineProcess 
  *  disable-features ConsolidatedMovementXY,InstalledApp,BackgroundFetch,WebOTP,WebPayments,WebUSB,PictureInPicture 
  *  disable-gpu  
  *  disable-setuid-sandbox  
  *  disable-speech-api  
  *  enable-features NetworkServiceInProcess,TracingServiceInProcess 
  *  enable-threaded-compositing  
  *  in-process-gpu  
  *  use-gl disabled 

[66533:66533:0322/161829.629687:ERROR:zygote_host_impl_linux.cc(90)] Running as root without --no-sandbox is not supported. See https://crbug.com/638180.

解决：
临时
export QTWEBENGINE_DISABLE_SANDBOX=1

永久
echo "export QTWEBENGINE_DISABLE_SANDBOX=1">>/etc/profile
source /etc/profile

#一大推lib报错处理
apt install -y libXcomposite* libXdamage* libXrandr* libXtst*  libfontconfig* libxkbcommon* libxkbfile* libGLX*
```

## 3. 源码安装

```Bash
curl -L https://calibre-ebook.com/dist/src | tar xvJ
cd calibre* && sudo python3 setup.py install
```