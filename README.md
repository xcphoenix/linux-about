- 编码批量转换
  
  ```shell
   find -name '*.java' -type f -print | xargs -i iconv -f GB18030 -t utf-8 {} -o {}
  ```
- PicGo-Cli上传
 
  ```shell
   picgo u | sed -n '/^http/p' | xsel -b -i
  ```
  
  > 需要使用 `npm install picgo -g` 安装 picgo

